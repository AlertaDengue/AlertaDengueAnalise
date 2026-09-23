# AlertaDengueAnalise

This repository runs the **Alerta Dengue** analytics pipeline in **R**, using
**Conda** and **Makim**. It reads a PostgreSQL database, produces per-state and
national `.RData` artifacts, generates SQL updates, and can produce incidence
maps. The container runs one analysis job and exits.

## Requirements

- Linux, Docker with Compose, and Containers Sugar for container operation.
- An accessible PostgreSQL database and the external InfoDengue Docker network
  for the chosen container profile.
- Miniforge/Mambaforge with `mamba` or `conda` for native execution.

## Environment configuration

Copy the tracked template, then edit `ALERTA_DB_HOST`, `ALERTA_DB_PORT`,
`ALERTA_DB_NAME`, `ALERTA_DB_USER`, and `ALERTA_DB_PASSWORD` for the database
you intend to use:

```bash
cp .env.tpl .env
export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"
mkdir -p artifacts
```

`.env` is local and gitignored; `.env.tpl` contains no secrets. Check that its
credentials match the chosen environment before any run. Each Sugar profile
uses a separate external InfoDengue network by default:

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

The image is `alertadengueanalise:local` and is shared by all profiles. The
profile selects runtime network and database environment wiring.

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

For the actual production refresh, choose `N` based on validated database and
container capacity:

```bash
ALERTA_OUTPUT_DIR="$(pwd)/artifacts" \
sugar --profile prod compose run \
  --service analysis \
  --options "--rm" \
  --cmd "makim pipeline.refresh-alertas-job \
    --week YYYYWW \
    --states ALL \
    --cores <N> \
    --load true"
```

`db.check` must succeed against the intended production database first.
`--load true` writes generated SQL to PostgreSQL; maps are generated only after
SQL loading. Each command starts one job that exits when complete.

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

## Direct Docker debugging

For image-level debugging, use direct Docker commands:

```bash
docker build -f containers/Dockerfile -t alertadengueanalise:local .
docker run --rm alertadengueanalise:local makim deps.check
```

Supply `--network`, `--env-file`, and a `/outputs` mount for database or
artifact checks. Normal operations use the Sugar profiles above.

## Troubleshooting

- For missing R packages, run `makim deps.check`; native installations can run
  `makim deps.install --env alertadengueanalise`.
- For a failed DB check, inspect the chosen profile's external network and the
  `ALERTA_DB_*` values in `.env`.
- For a long run with little console output, inspect CPU activity and the
  output directory's `logs/` and `alertas/YYYYWW/` files.
- For detailed execution behavior, see [workflow mechanics](docs/WORKFLOW.md).
