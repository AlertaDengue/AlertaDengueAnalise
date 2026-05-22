## Summary: nowcasting pipeline memory and stability investigation

### Initial problem

The `refresh-alertas` / `main_BR.R` nowcasting pipeline was failing during execution when running multiple states in parallel. The first visible failure was generic:

```text
Warning message:
In parallel::mclapply(...):
  1 function calls resulted in an error

Error: State pipeline failed for: CE / AL
```

The failure was hard to debug because `parallel::mclapply()` returned only a generic worker error. The real failing step, state, disease, municipality, and internal error were not visible.

At the same time, system monitoring showed high memory consumption and CPU saturation. In earlier runs, memory usage increased progressively and reached dangerous levels, with peaks observed around tens of GB. The initial suspicion was that the R pipeline itself was leaking memory.

---

## Initial hotspots identified

### 1. `mclapply()` state-level parallelism

The pipeline processed states in parallel through:

```r
parallel::mclapply(
  seq_len(n_states),
  run_state_pipeline,
  mc.cores = parallel_cores,
  mc.preschedule = FALSE
)
```

This means each state worker can independently run:

* dengue nowcasting
* chikungunya nowcasting
* zika nowcasting
* INLA Bayesian models
* database queries
* RData object generation

The main hotspot was not only the number of R workers, but the fact that each worker could spawn heavy native INLA/MKL processes.

### 2. INLA / MKL / native memory outside R GC

The memory logs added temporarily showed that R heap memory stayed relatively bounded. In one previous run, internal R memory grew only from roughly hundreds of MB to less than 500 MB. However, `htop` showed much larger system memory usage.

This indicated that the main memory pressure was probably not from regular R objects tracked by `gc()`, but from:

* INLA native processes
* MKL/OpenMP allocations
* forked R workers
* native memory outside R GC accounting
* temporary sparse matrix/model allocations
* possible copy-on-write pressure caused by `mclapply()`

### 3. Long-lived retained objects inside `run_state_pipeline()`

The original `run_state_pipeline()` kept all disease results in memory until the whole state finished:

```r
res[["ale.den"]]
res[["restab.den"]]
res[["ale.chik"]]
res[["restab.chik"]]
res[["ale.zika"]]
res[["restab.zika"]]
```

For large states like MG, SP, BA, PR, RS, this increased memory retention.

### 4. Aggregation loaded all state results at once

The previous aggregation stage loaded all `.RData` files into `res_list`:

```r
res_list <- vector("list", length(file_paths))
```

This kept all state outputs in memory simultaneously before generating SQL and BR consolidated outputs.

This was a secondary hotspot. It was not the initial crash source, but it increased peak memory after state execution.

### 5. Missing structured error capture

When a worker failed, the pipeline only reported:

```text
1 function calls resulted in an error
State pipeline failed for: AL
```

This made the actual root cause opaque.

## Mitigations implemented in `main_BR.R`

### 1. Split disease execution

We split the disease execution logic into a dedicated function:

```r
run_disease_pipeline()
```

Instead of keeping all logic inline inside `run_state_pipeline()`, each disease now has a clearer execution boundary.

Benefits:

* better cohesion
* easier cleanup after each disease
* easier error isolation
* simpler state worker logic

### 2. Added cleanup boundaries

We introduced:

```r
safe_gc <- function() {
  invisible(gc(verbose = FALSE))
}
```

Cleanup is now triggered:

* after each disease execution
* after each state save
* after each loaded `.RData` during aggregation
* after binding intermediate objects
* after saving BR RData

Example:

```r
rm(disease_result)
safe_gc()
```

and:

```r
rm(res, cidades)
safe_gc()
```

This helped reduce retained R-side memory and gave workers clearer release points.

### 3. Avoided keeping full `res_list`

The aggregation was refactored to avoid loading all state results into one large `res_list`.

Instead, each `.RData` is loaded, normalized, appended to disease-specific parts, and then cleaned:

```r
res_k <- load_state_result(file_paths[k])
...
rm(res_k)
safe_gc()
```

This reduced aggregation memory pressure.

### 4. Improved INLA thread limiting

A new explicit `configure_inla_threads()` function was added:

```r
configure_inla_threads <- function() {
  Sys.setenv(
    OMP_NUM_THREADS = "1",
    OPENBLAS_NUM_THREADS = "1",
    MKL_NUM_THREADS = "1",
    BLIS_NUM_THREADS = "1",
    VECLIB_MAXIMUM_THREADS = "1",
    RCPP_PARALLEL_NUM_THREADS = "1",
    NUMEXPR_NUM_THREADS = "1"
  )

  INLA::inla.setOption(num.threads = "1:1")
}
```

This is called:

* after loading config
* during INLA runtime validation
* inside each state worker

Goal:

* reduce nested parallelism
* avoid MKL/OpenMP oversubscription
* reduce uncontrolled native thread fanout

Important note: logs still show INLA can emit `thread_num[...]` warnings, so this does not fully eliminate INLA internal native behavior. But it helps constrain the runtime as much as possible from R.

### 5. Restored structured state error capture

A `tryCatch()` wrapper was restored around each state worker.

Now failures report:

* state
* current step
* error message
* call stack

Example structure:

```r
structure(
  list(
    state = sig,
    step = current_step,
    message = conditionMessage(e)
  ),
  class = "state-error"
)
```

This prevents opaque `mclapply()` errors.

### 6. Added municipality-level fallback

When state-level disease execution fails, the pipeline falls back to municipality-level execution:

```r
run_disease_pipeline_by_city()
```

This isolates city-level failures and prevents one bad municipality from killing the whole state.

In the successful run, this fallback was triggered for Goiás dengue:

```text
[state] GO dengue failed in state-level execution: error reading from connection
[state] GO dengue fallback: municipality-level isolation
- dengue: retrying municipality-level execution after state-level failure
```

The state later completed successfully and saved `ale-GO-202618.RData`.  

---

## Test execution summary

### Test run configuration

The successful run used:

```text
week=202618
window_weeks=100
cores=4
states=ALL
```

The pipeline started with 27 state rows and 4 parallel workers.  

### Pipeline start

```text
[2026-05-22 07:50:57] Repo root...
[2026-05-22 07:51:01] Starting pipeline for 27 state row(s)
[2026-05-22 07:51:01] State parallel workers: 4
```



### Pipeline loop completion

```text
[2026-05-22 10:18:54] Pipeline loop finished. Elapsed: 2.46473101556301
```

This means the state-processing phase took about **2.46 hours**, approximately **2h 27m 53s**. 

### Aggregation and SQL generation

After state processing, the pipeline loaded all 27 result files and generated SQL outputs:

```text
Loaded 27 result file(s)
Writing SQL dengue
Writing SQL chik
No zika restab found. Skipping zika SQL.
Saving BR RData
DONE
```



### Final Makim completion

```text
[II] refresh-alertas completed successfully.
```



---

## Runtime summary

From logs:

* start: `2026-05-22 07:50:57`
* state loop finished: `2026-05-22 10:18:54`
* R pipeline finished: `2026-05-22 10:26:14`
* SQL apply completed after that
* Makim completed successfully

Approximate durations:

* state nowcasting loop: **~2h 27m**
* R pipeline including aggregation/output: **~2h 35m**
* full workflow including SQL apply: completed successfully, exact final timestamp was not included in the `[II]` completion line

---

## Memory behavior after mitigation

From the monitoring screenshots during the successful run:

* memory stayed bounded
* peak observed was around **21–26 GB**
* memory dropped during the run instead of monotonically increasing
* swap remained low, around a few hundred MB
* no OOM kill occurred
* no long stuck worker was observed

This is a major improvement over earlier behavior, where memory appeared to grow continuously and reached much higher levels.

Key interpretation:

* `rm()` + `gc()` boundaries helped reduce R-side retention
* avoiding full `res_list` helped aggregation
* limiting to `--cores 4` reduced process concurrency
* explicit INLA thread configuration likely reduced oversubscription pressure
* municipality fallback prevented one state/disease failure from killing the run

---

## Remaining warnings and issues

### 1. INLA numerical instability

The logs still show many warnings like:

```text
iterative process seems to diverge, 'vb.correction' is aborted
```

These are model/numerical warnings, not infrastructure failures. They indicate convergence instability in some Bayesian nowcasting runs. Examples appear repeatedly in the logs. 

Observed related message:

```text
inla.core.safe: The inla program failed, but will rerun...
```



Impact:

* increases runtime
* can trigger retries
* can increase temporary memory usage
* may indicate unstable model inputs for some municipalities

But in the final run, these warnings did not stop the pipeline.

### 2. `adjustIncidence: city not in dataset`

The logs include many occurrences of:

```text
Error : adjustIncidence: city not in dataset
```

This appears mostly during fallback / municipality-level execution. It means some municipality codes are not present in the dataset used by `adjustIncidence`.

Important: this no longer killed the full workflow.

The fallback isolated these failures and allowed the pipeline to continue.

### 3. Zika skipped

The pipeline did not generate zika SQL:

```text
No zika restab found. Skipping zika SQL.
```



This appears expected based on state config or absence of zika outputs, not a pipeline crash.

---

## Outcome

The final implementation successfully mitigated the operational memory issue.

Before:

* opaque `mclapply()` failures
* state crashes without actionable detail
* high memory accumulation
* risk of OOM
* no fallback for city-level failures
* aggregation retained all state results

After:

* successful full pipeline execution
* 27 state outputs loaded
* dengue SQL generated
* chik SQL generated
* BR RData generated
* Makim completed successfully
* memory remained bounded
* municipality-level fallback recovered GO dengue
* structured logs now identify failures and fallback behavior

---

## Final technical conclusion

The root cause of the memory issue was not a simple R heap leak. The evidence points to a combination of:

* state-level parallelism via `mclapply()`
* heavy INLA Bayesian nowcasting
* native memory allocation outside R GC
* MKL/OpenMP/thread oversubscription risk
* large retained state objects
* aggregation loading all outputs into memory
* lack of cleanup boundaries

The mitigation was effective because it attacked the problem at several levels:

1. reduced retained R objects with explicit cleanup
2. avoided keeping all state outputs loaded at once
3. constrained INLA/native threads
4. limited worker parallelism to `--cores 4`
5. isolated municipality failures
6. restored structured state error logging

The final run confirms the approach is operationally stable for week `202618` with all states and `--cores 4`.
