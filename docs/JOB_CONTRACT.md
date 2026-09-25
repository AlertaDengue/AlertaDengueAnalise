# Analysis job contract

`makim pipeline.refresh-alertas-job` is the stable external runtime entrypoint
for the AlertaDengueAnalise OCI image. One invocation runs one finite analysis
job and exits. An external runner needs only the image, PostgreSQL access, job
arguments, and a writable `/outputs` mount. Containers Sugar is a convenience
for repository operators; it is not part of this contract.

## Inputs and results

Supply `ALERTA_DB_HOST`, `ALERTA_DB_PORT`, `ALERTA_DB_NAME`, `ALERTA_DB_USER`,
and `ALERTA_DB_PASSWORD` through the environment. Pass `--week YYYYWW`,
`--states ALL` or a comma-separated UF list, `--cores N`, and `--load true` or
`--load false`. Set `ALERTA_OUT_DIR=/outputs` for direct OCI execution and
mount a unique writable host directory at `/outputs`. Compose supplies that
container path automatically. `ALERTA_JOB_ID` and `ALERTA_INPUT_FINGERPRINT`
are optional per-invocation correlation metadata supplied by the external
runner, outside the deployment `.env`: if non-empty, the job writes them to
stdout and its `refresh-alertas-job-*.log` file. It does not calculate or
enforce them.

The job writes:

| Path | Contents |
| --- | --- |
| `/outputs/alertas/YYYYWW/` | Per-state `.RData` |
| `/outputs/alertas/BR/` | Consolidated national `.RData` |
| `/outputs/sql/` | Generated alert SQL |
| `/outputs/logs/` | Analysis and map logs |
| `/outputs/incidence_maps/` | Maps when `--load true` |

Exit status `0` means the job completed successfully. A non-zero status means
the external runner must treat it as failed. With `--load false`, the job
generates `.RData` and SQL, does not apply SQL, and skips maps. With
`--load true`, it applies generated SQL to PostgreSQL before generating maps.

## Ownership boundary

The external orchestrator owns ingestion-event consumption, readiness
decisions, A90/A92 same-epiweek coordination, input Run IDs, fingerprint
calculation, deduplication and idempotency, scheduling, retry policy, global
concurrency, job state and history, choosing the OCI image version or digest,
allocating a unique host output directory, and deciding when to launch a job.

AlertaDengueAnalise owns validation of its runtime arguments, scientific
execution, state-level parallelism, PostgreSQL reads, R/INLA execution,
generated `.RData` and SQL, optional SQL application, map generation, analysis
logs, and process exit status.

The `pipeline.refresh-alertas-job` OCI runtime must not require an
AlertaDengue checkout, an AlertFlow checkout, another sibling repository or
repository mount, Celery, RabbitMQ, Airflow, or an ingestion model.

## Scalability boundary

One analysis job can process states in parallel through `--cores`. Eight state
workers were validated with the current staging host and database capacity.
Each worker has its own PostgreSQL connection and isolated scratch directory.
Native and OpenMP threads are limited independently of the state worker count.

An external orchestrator may run workers on different hosts or nodes. Every
invocation needs an isolated host output directory and mount.
AlertaDengueAnalise does not implement a distributed scheduler.

Concurrent compute jobs using `--load false` can be orchestrated independently
when outputs are isolated. Concurrent `--load true` jobs against the same
PostgreSQL target have not been validated. Initial external orchestration must
serialize `--load true` jobs for the same database.
