# =============================================================================
# State incidence map generator
# =============================================================================

options(stringsAsFactors = FALSE)

log_msg <- function(..., level = "INFO") {
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  msg <- paste0(...)
  cat(sprintf("[%s] [%s] %s\n", ts, level, msg))
}

find_repo_root <- function(start_dir) {
  cur <- normalizePath(start_dir, winslash = "/", mustWork = FALSE)

  for (i in seq_len(8)) {
    has_script <- file.exists(file.path(cur, "main", "script_maps_state.R"))
    has_main <- file.exists(file.path(cur, "main", "main_BR.R"))
    has_cfg <- file.exists(file.path(cur, "config", "config_global_2020.R"))
    has_shape <- file.exists(
      file.path(cur, "r_maps_scripts", "dados", "shape", "muni_br.gpkg")
    )

    if ((has_script || has_main) && has_cfg && has_shape) {
      return(cur)
    }

    parent <- normalizePath(file.path(cur, ".."), winslash = "/", mustWork = FALSE)
    if (identical(parent, cur)) {
      break
    }

    cur <- parent
  }

  stop("Could not locate repo root from: ", start_dir, call. = FALSE)
}

get_env_any <- function(names, default = NULL) {
  for (nm in names) {
    val <- Sys.getenv(nm, unset = "")
    if (nzchar(val)) {
      return(val)
    }
  }

  default
}

configure_spatial_env <- function() {
  conda_prefix <- Sys.getenv("CONDA_PREFIX", unset = "")

  candidate_proj_dirs <- unique(c(
    Sys.getenv("PROJ_LIB", unset = ""),
    Sys.getenv("PROJ_DATA", unset = ""),
    if (nzchar(conda_prefix)) file.path(conda_prefix, "share", "proj") else "",
    "/usr/share/proj",
    "/usr/local/share/proj"
  ))

  candidate_proj_dirs <- candidate_proj_dirs[nzchar(candidate_proj_dirs)]
  proj_dirs <- candidate_proj_dirs[
    file.exists(file.path(candidate_proj_dirs, "proj.db"))
  ]

  if (length(proj_dirs) == 0) {
    stop(
      "Could not find proj.db. Set PROJ_LIB or PROJ_DATA to the directory containing proj.db.",
      call. = FALSE
    )
  }

  Sys.setenv(PROJ_LIB = proj_dirs[[1]])
  Sys.setenv(PROJ_DATA = proj_dirs[[1]])

  candidate_gdal_dirs <- unique(c(
    Sys.getenv("GDAL_DATA", unset = ""),
    if (nzchar(conda_prefix)) file.path(conda_prefix, "share", "gdal") else "",
    "/usr/share/gdal",
    "/usr/local/share/gdal"
  ))

  candidate_gdal_dirs <- candidate_gdal_dirs[nzchar(candidate_gdal_dirs)]
  gdal_dirs <- candidate_gdal_dirs[file.exists(candidate_gdal_dirs)]

  if (length(gdal_dirs) > 0) {
    Sys.setenv(GDAL_DATA = gdal_dirs[[1]])
  }

  log_msg("PROJ_LIB: ", Sys.getenv("PROJ_LIB"))
  log_msg("PROJ_DATA: ", Sys.getenv("PROJ_DATA"))
  log_msg("GDAL_DATA: ", Sys.getenv("GDAL_DATA", unset = ""))
}

load_required_packages <- function() {
  required_pkgs <- c(
    "DBI",
    "RPostgreSQL",
    "glue",
    "dplyr",
    "sf",
    "ggplot2",
    "tidyr",
    "purrr",
    "stringr",
    "tibble"
  )

  missing_pkgs <- required_pkgs[
    !vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)
  ]

  if (length(missing_pkgs) > 0) {
    stop(
      "Missing required R package(s): ",
      paste(missing_pkgs, collapse = ", "),
      ". Install dependencies before running this task.",
      call. = FALSE
    )
  }

  suppressPackageStartupMessages({
    library(DBI)
    library(RPostgreSQL)
    library(glue)
    library(dplyr)
    library(sf)
    library(ggplot2)
    library(tidyr)
    library(purrr)
    library(stringr)
    library(tibble)
  })
}

parse_csv_arg <- function(value, default = character(0)) {
  if (is.null(value) || !nzchar(value)) {
    return(default)
  }

  value <- trimws(value)

  if (toupper(value) == "ALL") {
    return("ALL")
  }

  items <- unlist(strsplit(value, ",", fixed = TRUE))
  items <- trimws(items)
  items <- items[nzchar(items)]

  unique(items)
}

normalize_diseases <- function(value) {
  diseases <- parse_csv_arg(value, default = "ALL")

  if (length(diseases) == 1 && diseases == "ALL") {
    return(c("dengue", "chikungunya", "zika"))
  }

  diseases <- tolower(diseases)

  aliases <- c(
    den = "dengue",
    dengue = "dengue",
    chik = "chikungunya",
    chikungunya = "chikungunya",
    zika = "zika",
    zikv = "zika"
  )

  normalized <- unname(aliases[diseases])

  if (any(is.na(normalized))) {
    invalid <- diseases[is.na(normalized)]
    stop(
      "Invalid disease value(s): ",
      paste(invalid, collapse = ", "),
      ". Expected: dengue, chikungunya, zika, or ALL.",
      call. = FALSE
    )
  }

  unique(normalized)
}

resolve_db_config <- function() {
  db_host <- get_env_any(c("ALERTA_DB_HOST", "DB_HOST"), default = "127.0.0.1")
  db_port <- as.integer(get_env_any(c("ALERTA_DB_PORT", "DB_PORT"), default = "5432"))
  db_name <- get_env_any(c("ALERTA_DB_NAME", "DB_NAME"), default = "dengue")
  db_user <- get_env_any(c("ALERTA_DB_USER", "DB_USER"), default = "")
  db_pass <- get_env_any(c("ALERTA_DB_PASSWORD", "DB_PASSWORD"), default = "")

  if (
    !nzchar(db_host) ||
      is.na(db_port) ||
      !nzchar(db_name) ||
      !nzchar(db_user) ||
      !nzchar(db_pass)
  ) {
    stop(
      "Missing database configuration. Check ALERTA_DB_* or DB_* variables.",
      call. = FALSE
    )
  }

  list(
    host = db_host,
    port = db_port,
    name = db_name,
    user = db_user,
    password = db_pass
  )
}

connect_db <- function(db_cfg) {
  log_msg(
    "Connecting DB: host=", db_cfg$host,
    " port=", db_cfg$port,
    " dbname=", db_cfg$name,
    " user=", db_cfg$user
  )

  con <- DBI::dbConnect(
    drv = RPostgreSQL::PostgreSQL(),
    dbname = db_cfg$name,
    host = db_cfg$host,
    port = db_cfg$port,
    user = db_cfg$user,
    password = db_cfg$password
  )

  invisible(DBI::dbGetQuery(con, "SELECT 1"))
  log_msg("DB connected OK")

  con
}

table_exists <- function(con, schema, table_name) {
  sql <- glue::glue_sql(
    '
    SELECT EXISTS (
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = {schema}
        AND table_name = {table_name}
    ) AS exists
    ',
    .con = con
  )

  isTRUE(DBI::dbGetQuery(con, as.character(sql))$exists[[1]])
}

get_disease_config <- function(disease) {
  configs <- list(
    dengue = list(
      label = "Dengue",
      slug = "dengue",
      table = "Historico_alerta",
      allow_empty = FALSE
    ),
    chikungunya = list(
      label = "Chikungunya",
      slug = "chikungunya",
      table = "Historico_alerta_chik",
      allow_empty = FALSE
    ),
    zika = list(
      label = "Zika",
      slug = "zika",
      table = "Historico_alerta_zika",
      allow_empty = TRUE
    )
  )

  cfg <- configs[[disease]]

  if (is.null(cfg)) {
    stop("Unsupported disease: ", disease, call. = FALSE)
  }

  cfg
}

legend_levels <- function() {
  c("0-10", "10-50", "50-100", "100-200", "200-300", "300 ou mais")
}

incidence_palette <- function() {
  c(
    "0-10" = "#FFF7EC",
    "10-50" = "#FDD49E",
    "50-100" = "#FC8D59",
    "100-200" = "#EF6548",
    "200-300" = "#B30000",
    "300 ou mais" = "#7F0000"
  )
}

get_state_rows <- function(states_arg) {
  states <- parse_csv_arg(states_arg, default = "ALL")

  if (!exists("estados_Infodengue", inherits = TRUE)) {
    stop("Object 'estados_Infodengue' not found in loaded config.", call. = FALSE)
  }

  state_rows <- estados_Infodengue

  if (!(length(states) == 1 && states == "ALL")) {
    states <- toupper(states)

    invalid_states <- setdiff(states, state_rows$sigla)
    if (length(invalid_states) > 0) {
      stop(
        "Invalid state value(s): ",
        paste(invalid_states, collapse = ", "),
        call. = FALSE
      )
    }

    state_rows <- state_rows[state_rows$sigla %in% states, , drop = FALSE]
  }

  if (nrow(state_rows) == 0) {
    stop("No states selected for map generation.", call. = FALSE)
  }

  state_rows
}

resolve_epiweek <- function(con, requested_week, states, diseases) {
  if (!identical(requested_week, "latest")) {
    return(as.integer(requested_week))
  }

  reference_tables <- c("Historico_alerta", "Historico_alerta_chik")
  reference_tables <- reference_tables[
    vapply(
      reference_tables,
      function(table_name) table_exists(con, "Municipio", table_name),
      logical(1)
    )
  ]

  if (length(reference_tables) == 0) {
    stop("Could not resolve latest SE: no reference alert table exists.", call. = FALSE)
  }

  state_names <- as.character(states$estado)

  latest_values <- purrr::map_int(reference_tables, function(table_name) {
    sql <- glue::glue_sql(
      '
      SELECT MAX(h."SE") AS latest_se
      FROM "Municipio".{`table_name`} h
      INNER JOIN "Dengue_global"."Municipio" m
        ON h."municipio_geocodigo" = m."geocodigo"
      WHERE m."uf" IN ({state_names*})
      ',
      .con = con
    )

    value <- DBI::dbGetQuery(con, as.character(sql))$latest_se[[1]]

    if (is.na(value)) {
      return(NA_integer_)
    }

    as.integer(value)
  })

  latest_values <- latest_values[!is.na(latest_values)]

  if (length(latest_values) == 0) {
    stop("Could not resolve latest SE from selected states.", call. = FALSE)
  }

  min(latest_values)
}

load_shape <- function(repo_root, states) {
  shape_path <- file.path(
    repo_root,
    "r_maps_scripts",
    "dados",
    "shape",
    "muni_br.gpkg"
  )

  if (!file.exists(shape_path)) {
    stop("Shape file not found: ", shape_path, call. = FALSE)
  }

  siglas <- as.character(states$sigla)
  shape <- sf::read_sf(shape_path)

  required_cols <- c("code_muni", "abbrev_state")
  missing_cols <- setdiff(required_cols, names(shape))

  if (length(missing_cols) > 0) {
    stop(
      "Shape file is missing required column(s): ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }

  shape |>
    dplyr::rename(CD_GEOCMU = code_muni) |>
    dplyr::mutate(CD_GEOCMU = sprintf("%07d", as.integer(CD_GEOCMU))) |>
    dplyr::filter(abbrev_state %in% siglas)
}

fetch_state_window_weeks <- function(con, state_name, epiweek, window_weeks) {
  reference_tables <- c("Historico_alerta", "Historico_alerta_chik")
  reference_tables <- reference_tables[
    vapply(
      reference_tables,
      function(table_name) table_exists(con, "Municipio", table_name),
      logical(1)
    )
  ]

  if (length(reference_tables) == 0) {
    return(integer())
  }

  queries <- purrr::map_chr(reference_tables, function(table_name) {
    glue::glue_sql(
      '
      SELECT DISTINCT h."SE"
      FROM "Municipio".{`table_name`} h
      INNER JOIN "Dengue_global"."Municipio" m
        ON h."municipio_geocodigo" = m."geocodigo"
      WHERE h."SE" <= {epiweek}
        AND m."uf" = {state_name}
      ',
      .con = con
    ) |>
      as.character()
  })

  sql <- paste(
    'SELECT DISTINCT "SE" FROM (',
    paste(queries, collapse = " UNION "),
    ') selected_weeks ORDER BY "SE" DESC LIMIT ',
    as.integer(window_weeks)
  )

  DBI::dbGetQuery(con, sql)$SE |>
    as.integer() |>
    sort()
}

fetch_incidence_data <- function(con, state_name, disease_cfg, reference_weeks) {
  table_name <- disease_cfg$table

  empty_result <- function() {
    tibble::tibble(
      SE = integer(),
      data_iniSE = as.Date(character()),
      cidade = integer(),
      nome = character(),
      uf_nome = character(),
      casos_est = numeric(),
      pop = numeric()
    )
  }

  if (length(reference_weeks) == 0) {
    return(empty_result())
  }

  if (!table_exists(con, "Municipio", table_name)) {
    if (isTRUE(disease_cfg$allow_empty)) {
      log_msg(
        "Table Municipio.", table_name,
        " not found. Generating empty map.",
        level = "WARN"
      )

      return(empty_result())
    }

    stop("Table Municipio.", table_name, " not found.", call. = FALSE)
  }

  sql <- glue::glue_sql(
    '
    SELECT
      h."SE",
      h."data_iniSE",
      h."municipio_geocodigo" AS cidade,
      m."nome" AS nome,
      m."uf" AS uf_nome,
      COALESCE(h."casos_est", 0) AS casos_est,
      COALESCE(h."pop", m."populacao") AS pop
    FROM "Municipio".{`table_name`} h
    INNER JOIN "Dengue_global"."Municipio" m
      ON h."municipio_geocodigo" = m."geocodigo"
    WHERE m."uf" = {state_name}
      AND h."SE" IN ({reference_weeks*})
    ',
    .con = con
  )

  DBI::dbGetQuery(con, as.character(sql)) |>
    dplyr::as_tibble()
}

calculate_accumulated_incidence <- function(data) {
  data |>
    dplyr::mutate(cidade_chr = sprintf("%07d", as.integer(cidade))) |>
    dplyr::group_by(cidade_chr, nome) |>
    dplyr::summarise(
      casos_est_window = sum(casos_est, na.rm = TRUE),
      pop = dplyr::first(pop),
      inc = dplyr::if_else(
        !is.na(pop) & pop > 0,
        (casos_est_window / pop) * 100000,
        NA_real_
      ),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      inc_interval = cut(
        inc,
        breaks = c(0, 10, 50, 100, 200, 300, Inf),
        labels = legend_levels(),
        include.lowest = TRUE,
        right = TRUE
      ),
      inc_interval = factor(as.character(inc_interval), levels = legend_levels())
    )
}

empty_incidence_data <- function(shape_state) {
  tibble::tibble(
    cidade_chr = as.character(shape_state$CD_GEOCMU),
    nome = NA_character_,
    casos_est_window = 0,
    pop = NA_real_,
    inc = 0,
    inc_interval = factor("0-10", levels = legend_levels())
  )
}

format_week_label <- function(weeks) {
  weeks <- sort(unique(as.integer(weeks)))

  if (length(weeks) == 0) {
    return("SE não disponível")
  }

  first_week <- weeks[[1]]
  last_week <- weeks[[length(weeks)]]

  year_first <- substr(first_week, 1, 4)
  year_last <- substr(last_week, 1, 4)

  week_first <- as.integer(substr(first_week, 5, 6))
  week_last <- as.integer(substr(last_week, 5, 6))

  if (length(weeks) == 1) {
    return(paste0("SE ", week_last, "/", year_last))
  }

  if (identical(year_first, year_last)) {
    return(paste0("SE ", week_first, "-", week_last, "/", year_last))
  }

  paste0("SE ", week_first, "/", year_first, " - ", week_last, "/", year_last)
}

map_theme <- function() {
  ggplot2::theme(
    plot.title = ggplot2::element_text(
      family = "Helvetica Neue",
      vjust = 1.5,
      hjust = 0.5,
      size = 14
    ),
    plot.subtitle = ggplot2::element_text(
      family = "Helvetica Neue",
      vjust = 2,
      hjust = 0.5,
      size = 10
    ),
    legend.direction = "horizontal",
    legend.position = "bottom",
    legend.title = ggplot2::element_text(
      family = "Helvetica Neue",
      size = 10
    ),
    legend.key.size = ggplot2::unit(0.4, "cm"),
    legend.text = ggplot2::element_text(
      family = "Helvetica Neue",
      size = 8
    ),
    axis.text = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank(),
    axis.title = ggplot2::element_blank(),
    panel.background = ggplot2::element_rect(fill = "transparent"),
    plot.background = ggplot2::element_rect(fill = "transparent", color = NA),
    panel.grid.major = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    legend.background = ggplot2::element_blank(),
    legend.box.background = ggplot2::element_blank()
  )
}

build_map <- function(shape_state, incidence_data, disease_cfg, subtitle) {
  levels_inc <- legend_levels()
  palette <- incidence_palette()

  map_data <- shape_state |>
    dplyr::left_join(incidence_data, by = c("CD_GEOCMU" = "cidade_chr")) |>
    dplyr::mutate(
      inc_interval = dplyr::if_else(
        is.na(as.character(inc_interval)),
        "0-10",
        as.character(inc_interval)
      ),
      inc_interval = factor(inc_interval, levels = levels_inc)
    )

  legend_data <- map_data[rep(1, length(levels_inc)), ]
  legend_data$inc_interval <- factor(levels_inc, levels = levels_inc)

  matched <- sum(!is.na(map_data$inc))
  unmatched <- sum(is.na(map_data$inc))

  log_msg("Joined municipalities with incidence data: ", matched)
  log_msg("Unmatched municipalities: ", unmatched)

  ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = map_data,
      ggplot2::aes(fill = inc_interval),
      linewidth = 0.02,
      color = "black",
      alpha = 1,
      show.legend = TRUE
    ) +
    ggplot2::geom_sf(
      data = legend_data,
      ggplot2::aes(fill = inc_interval),
      alpha = 0,
      color = NA,
      show.legend = TRUE
    ) +
    ggplot2::scale_fill_manual(
      values = palette,
      breaks = levels_inc,
      limits = levels_inc,
      labels = levels_inc,
      name = "Incidência por 100 mil habitantes",
      drop = FALSE,
      na.translate = FALSE,
      na.value = "transparent"
    ) +
    ggplot2::ggtitle(disease_cfg$label, subtitle = subtitle) +
    ggplot2::coord_sf(crs = sf::st_crs(shape_state), datum = NA) +
    map_theme() +
    ggplot2::guides(
      fill = ggplot2::guide_legend(
        title.position = "top",
        title.hjust = 0.5,
        nrow = 1,
        label.position = "bottom",
        override.aes = list(
          alpha = 1,
          color = NA
        )
      )
    )
}

save_map <- function(plot, output_dir, state_sigla, disease_cfg, epiweek) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  output_file <- file.path(
    output_dir,
    paste0("incidence_", state_sigla, "_", disease_cfg$slug, ".png")
  )

  grDevices::png(
    filename = output_file,
    width = 390,
    height = 404,
    bg = "transparent",
    units = "px",
    res = 85
  )

  print(plot)
  grDevices::dev.off()

  log_msg("Saved: ", normalizePath(output_file, winslash = "/", mustWork = FALSE))
  log_msg("Size KB: ", round(file.info(output_file)$size / 1024, 1))

  output_file
}

run_state_disease_map <- function(
  con,
  shape_data,
  state_row,
  disease,
  epiweek,
  window_weeks,
  output_dir
) {
  state_name <- as.character(state_row$estado)
  state_sigla <- as.character(state_row$sigla)
  disease_cfg <- get_disease_config(disease)

  log_msg(
    "[map] state=", state_sigla,
    " disease=", disease_cfg$slug,
    " week=", epiweek,
    " window_weeks=", window_weeks
  )

  shape_state <- shape_data |>
    dplyr::filter(abbrev_state == state_sigla)

  if (nrow(shape_state) == 0) {
    stop("No shape rows found for state: ", state_sigla, call. = FALSE)
  }

  reference_weeks <- fetch_state_window_weeks(
    con = con,
    state_name = state_name,
    epiweek = epiweek,
    window_weeks = window_weeks
  )

  subtitle <- format_week_label(reference_weeks)

  data <- fetch_incidence_data(
    con = con,
    state_name = state_name,
    disease_cfg = disease_cfg,
    reference_weeks = reference_weeks
  )

  log_msg("Query returned rows: ", nrow(data))

  if (nrow(data) == 0 && isTRUE(disease_cfg$allow_empty)) {
    log_msg(
      "No data found for state=", state_sigla,
      " disease=", disease_cfg$slug,
      ". Generating empty map.",
      level = "WARN"
    )

    incidence_data <- empty_incidence_data(shape_state)
  } else if (nrow(data) == 0) {
    log_msg(
      "No data found for state=", state_sigla,
      " disease=", disease_cfg$slug,
      " week=", epiweek,
      level = "WARN"
    )
    return(invisible(NULL))
  } else {
    incidence_data <- calculate_accumulated_incidence(data)
  }

  log_msg("Incidence calculated for municipalities: ", nrow(incidence_data))
  log_msg("Subtitle: ", subtitle)

  plot <- build_map(
    shape_state = shape_state,
    incidence_data = incidence_data,
    disease_cfg = disease_cfg,
    subtitle = subtitle
  )

  save_map(
    plot = plot,
    output_dir = output_dir,
    state_sigla = state_sigla,
    disease_cfg = disease_cfg,
    epiweek = epiweek
  )
}

main <- function() {
  configure_spatial_env()
  load_required_packages()

  args0 <- commandArgs(trailingOnly = FALSE)
  file_arg <- sub("^--file=", "", args0[grep("^--file=", args0)])
  script_dir <- if (length(file_arg)) {
    dirname(normalizePath(file_arg))
  } else {
    getwd()
  }

  repo_root <- find_repo_root(script_dir)
  setwd(repo_root)

  log_msg("Repo root: ", repo_root)

  cfg_path <- file.path(repo_root, "config", "config_global_2020.R")
  if (!file.exists(cfg_path)) {
    stop("Config file not found: ", cfg_path, call. = FALSE)
  }

  log_msg("Loading config: ", cfg_path)
  source(cfg_path)

  states_arg <- get_env_any(c("ALERTA_MAP_STATES"), default = "ALL")
  diseases_arg <- get_env_any(c("ALERTA_MAP_DISEASES"), default = "ALL")
  requested_week <- get_env_any(c("ALERTA_MAP_EPIWEEK"), default = "latest")
  output_dir <- get_env_any(
    c("ALERTA_MAP_OUTPUT_DIR"),
    default = file.path(repo_root, "sync_maps", "incidence_maps", "state")
  )

  window_weeks <- as.integer(
    get_env_any(c("ALERTA_MAP_WINDOW_WEEKS"), default = "4")
  )

  if (is.na(window_weeks) || window_weeks < 1) {
    stop("Invalid ALERTA_MAP_WINDOW_WEEKS.", call. = FALSE)
  }

  if (!identical(requested_week, "latest") && !grepl("^[0-9]{6}$", requested_week)) {
    stop(
      "Invalid ALERTA_MAP_EPIWEEK. Expected 'latest' or YYYYWW.",
      call. = FALSE
    )
  }

  diseases <- normalize_diseases(diseases_arg)
  state_rows <- get_state_rows(states_arg)

  db_cfg <- resolve_db_config()
  con <- connect_db(db_cfg)
  on.exit(try(DBI::dbDisconnect(con), silent = TRUE), add = TRUE)

  epiweek <- resolve_epiweek(
    con = con,
    requested_week = requested_week,
    states = state_rows,
    diseases = diseases
  )

  log_msg("Map epiweek: ", epiweek)
  log_msg("States: ", paste(state_rows$sigla, collapse = ", "))
  log_msg("Diseases: ", paste(diseases, collapse = ", "))
  log_msg("Window weeks: ", window_weeks)
  log_msg("Output dir: ", output_dir)

  shape_data <- load_shape(repo_root, state_rows)

  for (i in seq_len(nrow(state_rows))) {
    for (disease in diseases) {
      run_state_disease_map(
        con = con,
        shape_data = shape_data,
        state_row = state_rows[i, ],
        disease = disease,
        epiweek = epiweek,
        window_weeks = window_weeks,
        output_dir = output_dir
      )
    }
  }

  log_msg("DONE")
}

main()
