# AlertaDengueAnalise

This repository runs the **Alerta Dengue** analytics pipeline using **R**
within a **Conda environment**, orchestrated by **Makim** tasks.

It is designed to run against a **PostgreSQL** database (local container or
remote), generate per-state `.RData` artifacts, and produce SQL update scripts
for downstream systems.

## Requirements

- Linux
- Conda distribution (recommended: **Miniforge/Mambaforge**)
- `mamba` (recommended) or `conda`
- PostgreSQL database available (e.g., Docker container)

## Quick start

### 1) Create the Conda environment

Create the environment from the repository conda spec:

```bash
mamba env create -f conda/base.yaml -n alertadengueanalise -y
conda activate alertadengueanalise
```

### 2) Install R dependencies (CRAN + GitHub)

```bash
makim deps.install --env alertadengueanalise
```

Optional smoke test:

```bash
makim deps.check --env alertadengueanalise
```

### 3) Configure database access

Create a `.env` file at the repo root with your Postgres connection settings.

Supported variables:

* `DB_HOST`
* `DB_PORT`
* `DB_NAME`
* `DB_USER`
* `DB_PASSWORD`
* `DB_SSLMODE` (optional)

Example:

```env
ALERTA_DATA_RELATORIO=${ALERTA_DATA_RELATORIO}
ALERTA_OUT_DIR=${ALERTA_OUT_DIR}
ALERTA_DB_HOST=${ALERTA_DB_HOST}
ALERTA_DB_PORT=${ALERTA_DB_PORT}
ALERTA_DB_NAME=${ALERTA_DB_NAME}
ALERTA_DB_USER=${ALERTA_DB_USER}
ALERTA_DB_PASSWORD=${ALERTA_DB_PASSWORD}
ALERTA_DO_SCP=${ALERTA_DO_SCP} 
ALERTA_SCP_ENDPOINT=${ALERTA_SCP_ENDPOINT}
ALERTA_SCP_PATH=${ALERTA_SCP_PATH}
```

Check connectivity:

```bash
makim db.check --env alertadengueanalise
```

### 4) Run the BR pipeline for a given epidemiological week

Run the pipeline for week `YYYYWW` (example: `202601`):

```bash
makim pipeline.run-br --env alertadengueanalise --week 202601
```

To process states in parallel, add `--cores N`:

```bash
makim pipeline.run-br --env alertadengueanalise --week 202601 --cores 4
```

## Documentation

* Pipeline behavior and steps: `docs/WORKFLOW.md`
* Outputs and where to find them: `docs/OUTPUTS.md`

## Container batch job

The container is a one-shot analysis job. It includes the existing Conda/R,
INLA, Makim and PostgreSQL-client runtime, but no database credentials and no
AlertaDengue checkout. Build it from this repository:

Normal operational commands use Containers Sugar:

```bash
sugar --profile dev compose build
sugar --profile dev compose run --service analysis --options "--rm" \
  --cmd "makim deps.check"
```

The service exits after the requested command. To retain artifacts, select an
output directory before running the analysis job:

```bash
ALERTA_OUTPUT_DIR=/some/host/path \
  sugar --profile dev compose run --service analysis --options "--rm" \
  --cmd "makim pipeline.refresh-alertas-job --week YYYYWW --states DF --cores 1 --load false"
```

Direct Docker commands remain useful for debugging:

```bash
docker build -f containers/Dockerfile -t alertadengueanalise:local .
```

Run a dependency smoke test:

```bash
docker run --rm alertadengueanalise:local makim deps.check
```

Runtime variables may be supplied with `--env-file` or `-e`; a repository
`.env` is optional. To check a staging database on its Docker network:

```bash
docker run --rm --network <staging-network> --env-file <staging-env-file> \
  alertadengueanalise:local makim db.check
```

To run the existing limited integration suite against staging, use a known
historical staging week and state. The suite writes only to its temporary
sandbox.

```bash
docker run --rm --network <staging-network> --env-file <staging-env-file> \
  -e ALERTA_RUN_LOCAL_INTEGRATION=true -e ALERTA_TEST_STATE=DF \
  -e ALERTA_TEST_WEEK=<known-staging-week> \
  alertadengueanalise:local Rscript --vanilla tests/testthat.R
```

`pipeline.refresh-alertas-job` is the container-safe orchestration task. It
runs analysis and maps but never accesses the sibling AlertaDengue checkout or
publishes maps there. Mount an output directory to preserve artifacts after the
job exits. `--load false` is the safe default; setting `--load true` applies
generated SQL to the configured database.

```bash
docker run --rm --network <staging-network> --env-file <staging-env-file> \
  -v /some/host/path:/outputs -e ALERTA_OUT_DIR=/outputs \
  alertadengueanalise:local makim pipeline.refresh-alertas-job \
  --week YYYYWW --states DF --cores 1 --load false
```

## Troubleshooting

* If you see missing R packages during execution, run:

  ```bash
  makim deps.install --env alertadengueanalise
  ```
* If the pipeline runs long with little console output, check:

  * CPU usage: `ps -o pid,etime,pcpu,pmem,cmd -p <PID>`
  * New files created under `main/alertas/<YYYYWW>/`
  * Log file under `logs/` (if enabled by your pipeline wrapper)

## License
