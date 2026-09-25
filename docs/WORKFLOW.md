# Workflow

This document explains what happens when you run:

```bash
makim pipeline.run-br --week YYYYWW
```

To process multiple states at the same time, pass `--cores N`:

```bash
makim pipeline.run-br --week YYYYWW --cores 4
```

## High-level flow

1. **Load environment variables**

   * When present, Makim loads `.env` from the repository root and exports its
     variables into the process environment. A `.env` file is optional: values
     already supplied by the environment (for example Docker `--env-file`) are
     used directly.

2. **Set the epidemiological week**

   * Makim exports `ALERTA_DATA_RELATORIO=YYYYWW`.
   * The R pipeline uses that week to compute the report end date.

3. **Start the R entrypoint**

   * Makim runs:

     ```bash
     conda run -n <env> Rscript --vanilla main/main_BR.R
     ```

4. **Load global config**

   * `config/config_global_2020.R` is sourced.
   * This config:

     * loads required packages
     * defines `estados_Infodengue`
     * may disable INLA features if INLA is not installed

5. **Connect to PostgreSQL**

   * The pipeline prefers `ALERTA_DB_HOST`, `ALERTA_DB_PORT`,
     `ALERTA_DB_NAME`, `ALERTA_DB_USER`, and `ALERTA_DB_PASSWORD`.
     The corresponding `DB_*` names remain compatible.
   * A successful connection is required before data extraction.

6. **Run per-state processing**
   For each row in `estados_Infodengue`:

   * Resolve the list of municipalities for the chosen state.
   * Run disease pipelines depending on flags:

     * dengue (`cid10 = "A90"`)
     * chik (`cid10 = "A92.0"`)
     * zika (`cid10 = "A92.8"`)
   * The pipeline fetches raw notifications from the database, aggregates
     cases by onset date, runs alert computations, and builds historical
     tables.

   By default states run sequentially. When `--cores N` is greater than `1`,
   Makim exports `ALERTA_PARALLEL_CORES=N` and `main/main_BR.R` dispatches the
   state jobs with `parallel::mclapply()`. Each worker opens its own PostgreSQL
   connection and an isolated scratch directory, so choose `N` according to
   the database capacity.

7. **Persist per-state results**

   * Results are saved as `.RData` files under:
     `main/alertas/YYYYWW/`
   * Before state execution, the pipeline removes existing output files for
     the selected states and week. Other state files are left in place.

8. **Build consolidated outputs**
   After all states finish:

   * The pipeline requires and loads only the current run's selected-state
     `.RData` files. Stale files for other states cannot enter consolidation.
   * It consolidates tables (e.g., dengue/chik/zika historical tables).
   * It clears the three generated disease SQL paths before execution and
     writes current-run SQL scripts to `main/sql/`.

9. **Generate BR-level artifact**

   * A consolidated `.RData` is saved under:
     `main/alertas/BR/`
   * The current week's previous BR file is removed before execution. The
     pipeline requires a newly written nonempty BR file before completion;
     other weeks' BR files are untouched.

10. **Generate Incidence Maps (Optional)**

    After the pipeline completes and the database is updated with the new results, you can generate incidence maps:

    * **National Map**:
      ```bash
      makim pipeline.maps-br --week YYYYWW
      ```
      This executes `incidence_maps/br.R`.

    * **State Maps**:
      ```bash
      makim pipeline.maps-state --week YYYYWW --states ALL
      ```
      This executes `incidence_maps/state.R`.

    These scripts fetch data from the PostgreSQL database and use spatial data from `r_maps_scripts/dados/shape/` to produce PNG outputs in `sync_maps/incidence_maps/`.

## How to run a small test (single state)

To validate the setup with one state, pass `--states DF` to a refresh task.
This checks:

* database connectivity
* `.RData` output generation
* SQL generation

## Observability

Depending on your wrapper/pipeline version, you may see structured logs like:

* repo root
* config path
* week and end-date
* output directories
* DB connection target
* per-state progress

If console output is sparse during long runs:

* confirm the R process is still active
* check CPU usage
* verify if `main/alertas/YYYYWW/` is changing (file timestamps/size)

## Common causes of “stuck” runs

* Large state (many municipalities) + computationally heavy steps.
* Missing parallel backend (`parallel` package) causing failures when
  functions like `mclapply()` / `detectCores()` are referenced.
* Slow DB queries or database resource constraints (CPU/IO).
* Waiting on external network steps (disabled in local-only runs).

## Container-safe job

`makim pipeline.refresh-alertas-job` is the container-safe,
repository-independent entrypoint for analysis and optional map generation.
It does not access the sibling AlertaDengue repository. Use
`ALERTA_OUT_DIR` to direct analysis outputs to a mounted container volume; maps
are written below `<ALERTA_OUT_DIR>/incidence_maps/` when enabled.
The task writes `refresh-alertas-job-*.log` under the output `logs/` directory,
including job-level output-validation errors. Optional `ALERTA_JOB_ID` and
`ALERTA_INPUT_FINGERPRINT` are supplied per invocation by the runner.

- `--load false`: runs analysis, produces `.RData` and SQL update files, but does
  NOT apply SQL to PostgreSQL. Map generation is skipped because maps query
  PostgreSQL `Historico_alerta`, which still contains data from previous weeks.
- `--load true`: runs analysis, applies generated SQL to PostgreSQL, then
  generates BR and state incidence maps from the refreshed database tables.
  It requires nonempty current-run dengue and chik SQL before applying either
  file; missing SQL fails the job before any SQL application.

The older `pipeline.refresh-alertas-full` remains the host-only operational
task because it intentionally publishes into the sibling checkout and invokes
its history-update script.

The three Sugar profiles use the same one-shot `analysis` service and separate
external Infodengue networks:

| Profile | Overlay | Default external network |
| --- | --- | --- |
| dev | `containers/compose-dev.yaml` | `infodengue-dev_infodengue` |
| staging | `containers/compose-staging.yaml` | `infodengue-staging_infodengue` |
| prod | `containers/compose-prod.yaml` | `infodengue-prod_infodengue` |

Each overlay passes `ALERTA_DB_*` values into the container. A shell-level
`INFODENGUE_NETWORK` override can select another external network for one
command. See the [README](../README.md) for the exact build, check, analysis,
and SQL loading sequence. External runner semantics are in the
[job contract](JOB_CONTRACT.md).
