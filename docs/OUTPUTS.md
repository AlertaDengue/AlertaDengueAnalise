# Outputs

This repository produces three main output categories:

1) Per-state `.RData` artifacts  
2) SQL scripts (`output_*.sql`)  
3) BR-level consolidated `.RData`

All paths below are relative to the repository root.

## 1) Per-state results

For a given week `YYYYWW`, outputs are stored in:

```

main/alertas/YYYYWW/

```

Typical file naming:

- `ale-<SIGLA>-<YYYYWW>.RData`

Example:

- `main/alertas/202601/ale-RR-202601.RData`

These `.RData` files contain the per-state computed results (alerts and
historical tables) used later for SQL generation and BR aggregation.

## 2) SQL scripts

SQL scripts are written to:

```

main/sql/

```

Typical files:

- `output_dengue.sql`
- `output_chik.sql`
- `output_zika.sql`

Notes:

- If a disease is disabled (e.g., `chik = FALSE`), the corresponding SQL output
  may not be generated.
- Empty or missing SQL files usually indicate that the pipeline did not reach
  the consolidation stage or that no valid disease tables were produced.

## 3) BR consolidated artifact

The BR consolidated artifact is written to:

```

main/alertas/BR/

```

Typical file:

- `ale-BR-<YYYYWW>.RData`

Example:

- `main/alertas/BR/ale-BR-202601.RData`

This file is intended for downstream reporting/boletins workflows.

## Verifying outputs after a run

After:

```bash
makim pipeline.run-br --week 202601
```

Check:

```bash
ls -lh main/alertas/202601/
ls -lh main/sql/
ls -lh main/alertas/BR/
```

Expected:

* At least one `ale-*-202601.RData` file exists under `main/alertas/202601/`.
* At least one SQL file exists under `main/sql/` (for enabled diseases).
* A BR `.RData` exists under `main/alertas/BR/` if consolidation completed.


## 4) Incidence Maps

Incidence maps are generated as PNG images and stored in:

```

sync_maps/incidence_maps/

```

Subdirectories:

- `country/`: National-level maps (e.g., `incidence_Nacional_dengue.png`)
- `state/`: State-level maps (e.g., `incidence_RJ_dengue_SE202617.png`)

These maps are generated using the scripts in `incidence_maps/` and require spatial data located in `r_maps_scripts/dados/shape/`.

## Verifying outputs after a run
...
Check:

```bash
ls -lh main/alertas/202601/
ls -lh main/sql/
ls -lh main/alertas/BR/
ls -lh sync_maps/incidence_maps/country/
ls -lh sync_maps/incidence_maps/state/
```

Expected:

* PNG maps are generated in the corresponding `sync_maps/incidence_maps/` directories.

```

---