# Workflow

This document explains what happens when you run:

```bash
makim pipeline.run-br --week YYYYWW
```

## High-level flow

1. **Load environment variables**

   * Makim loads `.env` from the repository root and exports the variables
     into the process environment.

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

   * The pipeline uses `DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASSWORD`.
   * A successful connection is required before data extraction.

6. **Run per-state processing**
   For each row in `estados_Infodengue`:

   * Resolve the list of municipalities for the chosen state.
   * Run disease pipelines depending on flags:

     * dengue (`cid10 = "A90"`)
     * chik (`cid10 = "A92"`)
     * zika (`cid10 = "A92.8"`)
   * The pipeline fetches raw notifications from the database, aggregates
     cases by onset date, runs alert computations, and builds historical
     tables.

7. **Persist per-state results**

   * Results are saved as `.RData` files under:
     `main/alertas/YYYYWW/`

8. **Build consolidated outputs**
   After all states finish:

   * The pipeline loads all state `.RData` files for the week.
   * It consolidates tables (e.g., dengue/chik/zika historical tables).
   * It writes SQL scripts to `main/sql/`.

9. **Generate BR-level artifact**

   * A consolidated `.RData` is saved under:
     `main/alertas/BR/`

## How to run a small test (single state)

To validate the setup quickly, configure `estados_Infodengue` with a single row
and run only dengue (disable chik/zika). This is the recommended first check to:

* confirm DB connectivity
* confirm the pipeline produces `.RData`
* confirm SQL generation

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
