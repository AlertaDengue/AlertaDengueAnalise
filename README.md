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

## Documentation

* Pipeline behavior and steps: `docs/WORKFLOW.md`
* Outputs and where to find them: `docs/OUTPUTS.md`

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
