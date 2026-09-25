# AlertaDengueAnalise

This repository runs the **AlertaDengue** analytics pipeline in **R**, using
**Conda** and **Makim**. It reads a PostgreSQL database, produces per-state and
national `.RData` artifacts, generates SQL updates, and can produce incidence
maps. The container runs one analysis job and exits.

## Requirements

- Linux, Docker with Compose, and Containers Sugar for container operation.
- An accessible PostgreSQL database and the external Infodengue Docker network
  for the chosen container profile.
- Miniforge/Mambaforge with `mamba` or `conda` for native execution.
- GNU gettext utilities (`envsubst`) on the host that generates `.env`.

## Environment configuration

Set deployment-specific values in the shell, then materialize the tracked
placeholder template with `envsubst`:

```bash
export ALERTA_DB_HOST="<database-host>"
export ALERTA_DB_PORT="<database-port>"
export ALERTA_DB_NAME="<database-name>"
export ALERTA_DB_USER="<database-user>"
export ALERTA_DB_PASSWORD="<database-password>"
export ALERTA_OUTPUT_DIR="$(pwd)/artifacts"
export ALERTA_OUT_DIR=""
export ALERTA_DO_SCP="false"
export ALERTA_SCP_ENDPOINT=""
export ALERTA_SCP_PATH=""

envsubst < .env.tpl > .env
export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"
mkdir -p artifacts
```

`.env.tpl` is tracked and contains deployment placeholders only. `.env` is
generated locally and gitignored. Keep deployment values in the shell or
deployment environment; never commit secrets. Optional `ALERTA_JOB_ID` and
`ALERTA_INPUT_FINGERPRINT` identify one invocation and are supplied by its
runner, outside the long-lived `.env`. Each Sugar profile uses a separate
external Infodengue network by default:

| Profile | Default network |
| --- | --- |
| dev | `infodengue-dev_infodengue` |
| staging | `infodengue-staging_infodengue` |
| prod | `infodengue-prod_infodengue` |

For a deployment with another network name, override it for that command:

```bash
INFODENGUE_NETWORK=<network> sugar --profile <profile> compose run ...
```

Keep `INFODENGUE_NETWORK` out of the shared `.env` file so a profile cannot
inherit another environment's network. The container takes its report week from
`--week` and mounts host `${ALERTA_OUTPUT_DIR}` at `/outputs`. Pass an absolute
`ALERTA_OUTPUT_DIR`, as shown in the analysis commands below, so Compose mounts
the intended repository-level `artifacts/` directory. Relative paths are
resolved from `containers/`, where the base Compose file lives.

## Native/Conda execution

```bash
mamba env create -f conda/base.yaml -n alertadengueanalise -y
conda activate alertadengueanalise
makim deps.install --env alertadengueanalise
makim deps.check --env alertadengueanalise
makim db.check --env alertadengueanalise
makim pipeline.run-br --env alertadengueanalise --week YYYYWW
```

For native runs, `ALERTA_OUT_DIR` can select another output root; when empty,
the pipeline uses the repository's `main/` output tree. Set `--cores N` only
after checking database capacity. The native `pipeline.refresh-alertas` task
can apply SQL with `--load true`; review its target before doing so.

## Container execution

Sugar uses `containers/compose.yaml` plus the chosen profile's network and DB
overlay. The `analysis` service is a one-shot batch job, not a persistent
daemon. Use `compose run` for each operation; `docker compose up` is not the
normal analysis workflow.

### Build

```bash
export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"
mkdir -p artifacts

sugar --profile dev compose build
sugar --profile dev compose run \
  --service analysis \
  --options "--rm" \
  --cmd "makim deps.check"
```

The image defaults to `alertadengueanalise:local` and is shared by all profiles.
Set `ALERTA_ANALYSIS_IMAGE` to select another OCI image. The profile selects
runtime network and database environment wiring.

### Development

Check the selected development database:

```bash
sugar --profile dev compose run \
  --service analysis \
  --options "--rm" \
  --cmd "makim db.check"
```

Run analysis and generate local artifacts without applying SQL:

```bash
ALERTA_OUTPUT_DIR="$(pwd)/artifacts" \
sugar --profile dev compose run \
  --service analysis \
  --options "--rm" \
  --cmd "makim pipeline.refresh-alertas-job \
    --week YYYYWW \
    --states DF \
    --cores 1 \
    --load false"
```

When a database refresh is intended, verify the target and run the write job:

```bash
ALERTA_OUTPUT_DIR="$(pwd)/artifacts" \
sugar --profile dev compose run \
  --service analysis \
  --options "--rm" \
  --cmd "makim pipeline.refresh-alertas-job \
    --week YYYYWW \
    --states DF \
    --cores 1 \
    --load true"
```

`--load false` performs analysis and writes `.RData` and SQL files; it does not
apply SQL to PostgreSQL or generate maps. `--load true` performs analysis,
applies the generated SQL, then generates BR and state maps.

### Staging

Check connectivity, then start with a run that does not write to PostgreSQL:

```bash
sugar --profile staging compose run \
  --service analysis \
  --options "--rm" \
  --cmd "makim db.check"

ALERTA_OUTPUT_DIR="$(pwd)/artifacts" \
sugar --profile staging compose run \
  --service analysis \
  --options "--rm" \
  --cmd "makim pipeline.refresh-alertas-job \
    --week YYYYWW \
    --states DF \
    --cores 1 \
    --load false"
```

Use `--load true` only when you intend to apply the generated SQL to the
verified staging database; maps follow SQL loading.

### Production

First verify that credentials and the network reach the intended production
database:

```bash
sugar --profile prod compose run \
  --service analysis \
  --options "--rm" \
  --cmd "makim db.check"
```

Run a single-state analysis without database writes:

```bash
ALERTA_OUTPUT_DIR="$(pwd)/artifacts" \
sugar --profile prod compose run \
  --service analysis \
  --options "--rm" \
  --cmd "makim pipeline.refresh-alertas-job \
    --week YYYYWW \
    --states DF \
    --cores 1 \
    --load false"
```

For the actual production refresh:

```bash
ALERTA_OUTPUT_DIR="$(pwd)/artifacts" \
sugar --profile prod compose run \
  --service analysis \
  --options "--rm" \
  --cmd "makim pipeline.refresh-alertas-job \
    --week YYYYWW \
    --states ALL \
    --cores 8 \
    --load true"
```

`db.check` must succeed against the intended production database first.
`--load true` writes generated SQL to PostgreSQL; maps are generated only after
SQL loading. Each command starts one job that exits when complete. Eight workers
were validated with the current staging host and database capacity; reconsider
this value if either capacity changes.

## Outputs

Container outputs are persisted on the host at `${ALERTA_OUTPUT_DIR}` and
visible in the container at `/outputs`:

```text
/outputs/alertas/YYYYWW/
/outputs/alertas/BR/
/outputs/sql/
/outputs/logs/
/outputs/incidence_maps/
```

With `--load false`, `incidence_maps` is not generated. With `--load true`, SQL
is applied before maps are generated. See [output details](docs/OUTPUTS.md).

## External runner / OCI contract

An external runner can launch the same finite job directly from an OCI image:

```bash
docker run --rm \
  --network <target-network> \
  --env-file <deployment-env> \
  -e ALERTA_JOB_ID="<job-id>" \
  -e ALERTA_INPUT_FINGERPRINT="<fingerprint>" \
  -e ALERTA_OUT_DIR=/outputs \
  -v <unique-output-dir>:/outputs \
  <analysis-image> \
  makim pipeline.refresh-alertas-job \
    --week YYYYWW \
    --states ALL \
    --cores 8 \
    --load true
```

The env file supplies deployment settings. The two metadata variables are
optional and belong to this invocation. Each concurrent invocation needs its
own writable output mount and host path.
Containers Sugar is an operational convenience for this repository. It is not
part of the external analysis job contract. See the [job contract](docs/JOB_CONTRACT.md)
for exit status, output paths, and ownership boundaries.

For local image checks, use direct Docker commands:

```bash
docker build -f containers/Dockerfile -t alertadengueanalise:local .
docker run --rm alertadengueanalise:local makim deps.check
```

Normal repository operations use the Sugar profiles above.

## Troubleshooting

- For missing R packages, run `makim deps.check`; native installations can run
  `makim deps.install --env alertadengueanalise`.
- For a failed DB check, inspect the chosen profile's external network and the
  `ALERTA_DB_*` values in `.env`.
- For a long run with little console output, inspect CPU activity and the
  output directory's `logs/` and `alertas/YYYYWW/` files.
- For detailed execution behavior, see [workflow mechanics](docs/WORKFLOW.md).
