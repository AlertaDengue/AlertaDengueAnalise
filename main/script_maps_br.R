#!/usr/bin/env Rscript

options(stringsAsFactors = FALSE)

log_msg <- function(..., level = "INFO") {
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  cat(sprintf("[%s] [%s] %s\n", ts, level, paste0(...)))
}

get_env_any <- function(names, default = "") {
  for (name in names) {
    value <- Sys.getenv(name, unset = "")
    if (nzchar(value)) {
      return(value)
    }
  }
  default
}

find_repo_root <- function(start_dir) {
  cur <- normalizePath(start_dir, winslash = "/", mustWork = FALSE)

  for (i in seq_len(8)) {
    if (
      file.exists(file.path(cur, ".makim.yaml")) ||
        file.exists(file.path(cur, "main", "main_BR.R"))
    ) {
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

configure_spatial_env <- function() {
  conda_prefix <- Sys.getenv("CONDA_PREFIX", unset = "")

  proj_candidates <- unique(c(
    Sys.getenv("PROJ_LIB", unset = ""),
    Sys.getenv("PROJ_DATA", unset = ""),
    if (nzchar(conda_prefix)) file.path(conda_prefix, "share", "proj") else "",
    "/usr/share/proj",
    "/usr/local/share/proj"
  ))

  proj_candidates <- proj_candidates[nzchar(proj_candidates)]
  proj_dirs <- proj_candidates[file.exists(file.path(proj_candidates, "proj.db"))]

  if (length(proj_dirs) == 0) {
    stop("Could not find proj.db. Check PROJ_LIB/PROJ_DATA.", call. = FALSE)
  }

  Sys.setenv(PROJ_LIB = proj_dirs[[1]])
  Sys.setenv(PROJ_DATA = proj_dirs[[1]])

  gdal_candidates <- unique(c(
    Sys.getenv("GDAL_DATA", unset = ""),
    if (nzchar(conda_prefix)) file.path(conda_prefix, "share", "gdal") else "",
    "/usr/share/gdal",
    "/usr/local/share/gdal"
  ))

  gdal_candidates <- gdal_candidates[nzchar(gdal_candidates)]
  gdal_dirs <- gdal_candidates[file.exists(gdal_candidates)]

  if (length(gdal_dirs) > 0) {
    Sys.setenv(GDAL_DATA = gdal_dirs[[1]])
  }

  log_msg("PROJ_LIB: ", Sys.getenv("PROJ_LIB"))
  log_msg("PROJ_DATA: ", Sys.getenv("PROJ_DATA"))
  log_msg("GDAL_DATA: ", Sys.getenv("GDAL_DATA", unset = ""))
}

load_required_packages <- function() {
  packages <- c(
    "DBI",
    "RPostgreSQL",
    "glue",
    "dplyr",
    "sf",
    "ggplot2",
    "purrr"
  )

  missing <- packages[
    !vapply(packages, requireNamespace, logical(1), quietly = TRUE)
  ]

  if (length(missing) > 0) {
    stop(
      "Missing required R package(s): ",
      paste(missing, collapse = ", "),
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
    library(purrr)
  })
}

parse_diseases <- function(value) {
  if (!nzchar(value) || toupper(value) == "ALL") {
    return(c("dengue", "chikungunya"))
  }

  diseases <- strsplit(value, ",", fixed = TRUE)[[1]]
  diseases <- tolower(trimws(diseases))
  diseases <- diseases[nzchar(diseases)]

  aliases <- c(
    dengue = "dengue",
    den = "dengue",
    chikungunya = "chikungunya",
    chik = "chikungunya"
  )

  normalized <- unname(aliases[diseases])

  if (any(is.na(normalized))) {
    stop(
      "Invalid disease value(s): ",
      paste(diseases[is.na(normalized)], collapse = ", "),
      call. = FALSE
    )
  }

  unique(normalized)
}

get_disease_config <- function(disease) {
  configs <- list(
    dengue = list(
      label = "Dengue",
      slug = "dengue",
      cid10 = "A90",
      table = "Historico_alerta"
    ),
    chikungunya = list(
      label = "Chikungunya",
      slug = "chikungunya",
      cid10 = "A92.0",
      table = "Historico_alerta_chik"
    )
  )

  cfg <- configs[[disease]]

  if (is.null(cfg)) {
    stop("Unsupported disease: ", disease, call. = FALSE)
  }

  cfg
}

connect_db <- function() {
  db_host <- get_env_any(c("ALERTA_DB_HOST", "DB_HOST"), "127.0.0.1")
  db_port <- as.integer(get_env_any(c("ALERTA_DB_PORT", "DB_PORT"), "5432"))
  db_name <- get_env_any(c("ALERTA_DB_NAME", "DB_NAME"), "dengue")
  db_user <- get_env_any(c("ALERTA_DB_USER", "DB_USER"))
  db_pass <- get_env_any(c("ALERTA_DB_PASSWORD", "DB_PASSWORD"))

  if (!nzchar(db_user) || !nzchar(db_pass)) {
    stop("Missing DB user/password. Check ALERTA_DB_* or DB_* variables.", call. = FALSE)
  }

  log_msg(
    "Connecting DB: host=", db_host,
    " port=", db_port,
    " dbname=", db_name,
    " user=", db_user
  )

  con <- DBI::dbConnect(
    drv = RPostgreSQL::PostgreSQL(),
    dbname = db_name,
    host = db_host,
    port = db_port,
    user = db_user,
    password = db_pass
  )

  invisible(DBI::dbGetQuery(con, "SELECT 1"))
  log_msg("DB connected OK")

  con
}

resolve_epiweek <- function(con, requested_week, disease_configs) {
  if (!identical(requested_week, "latest")) {
    return(as.integer(requested_week))
  }

  latest_values <- purrr::map_int(disease_configs, function(cfg) {
    sql <- glue::glue_sql(
      'SELECT MAX("SE") AS latest_se FROM "Municipio".{`cfg$table`}',
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
    stop("Could not resolve latest SE.", call. = FALSE)
  }

  min(latest_values)
}

fetch_country_data <- function(con, cfg, epiweek, window_weeks) {
  sql <- glue::glue_sql(
    '
    WITH selected_se AS (
      SELECT DISTINCT "SE"
      FROM "Municipio".{`cfg$table`}
      WHERE "SE" <= {epiweek}
      ORDER BY "SE" DESC
      LIMIT {window_weeks}
    )
    SELECT
      h."SE",
      h."municipio_geocodigo",
      m."id_regional" AS regional_codigo,
      COALESCE(h."casos_est", 0) AS casos_est,
      COALESCE(h."pop", m."populacao") AS pop,
      {cfg$cid10} AS "CID10"
    FROM "Municipio".{`cfg$table`} h
    INNER JOIN "Dengue_global"."Municipio" m
      ON h."municipio_geocodigo" = m."geocodigo"
    INNER JOIN selected_se s
      ON h."SE" = s."SE"
    WHERE m."id_regional" IS NOT NULL
    ',
    .con = con
  )

  DBI::dbGetQuery(con, as.character(sql)) |>
    dplyr::as_tibble() |>
    dplyr::mutate(
      SE = as.integer(SE),
      regional_codigo = as.numeric(regional_codigo),
      casos_est = as.numeric(casos_est),
      pop = as.numeric(pop)
    )
}

calculate_incidence <- function(data) {
  legend_levels <- c(
    "0-10",
    "10-50",
    "50-100",
    "100-200",
    "200-300",
    "300 ou mais"
  )

  data |>
    dplyr::group_by(regional_codigo, CID10) |>
    dplyr::summarise(
      casos_est_window = sum(casos_est, na.rm = TRUE),
      pop = sum(pop, na.rm = TRUE) / dplyr::n_distinct(SE),
      inc = dplyr::if_else(
        !is.na(pop) & pop > 0,
        casos_est_window / pop * 100000,
        NA_real_
      ),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      inc_interval = cut(
        inc,
        breaks = c(0, 10, 50, 100, 200, 300, Inf),
        labels = legend_levels,
        include.lowest = TRUE,
        right = TRUE
      ),
      inc_interval = factor(
        as.character(inc_interval),
        levels = legend_levels
      )
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

load_shapes <- function(repo_root) {
  region_path <- file.path(
    repo_root,
    "r_maps_scripts",
    "dados",
    "shape",
    "rs_450_RepCor1.shp"
  )

  br_path <- file.path(
    repo_root,
    "r_maps_scripts",
    "dados",
    "shape",
    "UFEBRASIL.shp"
  )

  if (!file.exists(region_path)) {
    stop("Regional shape file not found: ", region_path, call. = FALSE)
  }

  if (!file.exists(br_path)) {
    stop("Brazil outline shape file not found: ", br_path, call. = FALSE)
  }

  regions <- sf::read_sf(region_path)
  br <- sf::read_sf(br_path)

  primary_col <- intersect(
    c("primary id", "primary.id", "primary_id", "primaryid", "primary"),
    names(regions)
  )

  if (length(primary_col) == 0) {
    stop(
      "Regional shape is missing primary id column. Available columns: ",
      paste(names(regions), collapse = ", "),
      call. = FALSE
    )
  }

  regions <- regions |>
    dplyr::mutate(primary_id = as.numeric(.data[[primary_col[[1]]]]))

  list(regions = regions, br = br)
}

get_plot_limits <- function(sf_obj) {
  bbox <- sf::st_bbox(sf_obj)

  dx <- bbox[["xmax"]] - bbox[["xmin"]]
  dy <- bbox[["ymax"]] - bbox[["ymin"]]

  list(
    xlim = c(
      bbox[["xmin"]] - dx * 0.24,
      bbox[["xmax"]] + dx * 0.02
    ),
    ylim = c(
      bbox[["ymin"]] - dy * 0.08,
      bbox[["ymax"]] + dy * 0.02
    )
  )
}

map_theme <- function() {
  ggplot2::theme(
    plot.title = ggplot2::element_text(
      family = "Helvetica Neue",
      size = 14,
      hjust = 0.5,
      vjust = 1.3
    ),
    plot.subtitle = ggplot2::element_text(
      family = "Helvetica Neue",
      size = 11,
      hjust = 0.5,
      vjust = 1.6
    ),
    legend.position = c(0.05, 0.11),
    legend.justification = c(0, 0),
    legend.direction = "vertical",
    legend.background = ggplot2::element_rect(
      fill = "transparent",
      colour = NA
    ),
    legend.box.background = ggplot2::element_rect(
      fill = "transparent",
      colour = NA
    ),
    legend.key = ggplot2::element_rect(
      fill = "transparent",
      colour = NA
    ),
    legend.title = ggplot2::element_text(
      family = "Helvetica Neue",
      size = 9,
      hjust = 0
    ),
    legend.title.align = 0,
    legend.text = ggplot2::element_text(
      family = "Helvetica Neue",
      size = 8,
      hjust = 0
    ),
    legend.text.align = 0,
    legend.key.width = ggplot2::unit(0.36, "cm"),
    legend.key.height = ggplot2::unit(0.36, "cm"),
    legend.spacing.y = ggplot2::unit(0.01, "cm"),
    plot.background = ggplot2::element_rect(
      fill = "transparent",
      colour = NA
    ),
    panel.background = ggplot2::element_rect(
      fill = "transparent",
      colour = NA
    ),
    panel.grid.major = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    axis.text = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank(),
    axis.title = ggplot2::element_blank(),
    plot.margin = ggplot2::margin(8, 8, 8, 8)
  )
}

build_map <- function(regions, br, incidence, cfg, subtitle) {
  legend_levels <- c(
    "0-10",
    "10-50",
    "50-100",
    "100-200",
    "200-300",
    "300 ou mais"
  )

  palette <- c(
    "0-10" = "#FFF7EC",
    "10-50" = "#FDD49E",
    "50-100" = "#FC8D59",
    "100-200" = "#EF6548",
    "200-300" = "#B30000",
    "300 ou mais" = "#7F0000"
  )

  map_data <- regions |>
    dplyr::left_join(incidence, by = c("primary_id" = "regional_codigo")) |>
    dplyr::mutate(
      inc_interval = factor(
        as.character(inc_interval),
        levels = legend_levels
      )
    )

  plot_limits <- get_plot_limits(br)

  log_msg("Joined regions with incidence data: ", sum(!is.na(map_data$inc)))
  log_msg("Unmatched regions: ", sum(is.na(map_data$inc)))

  ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = map_data,
      ggplot2::aes(fill = inc_interval),
      linewidth = 0.02,
      color = "grey80",
      alpha = 1,
      show.legend = TRUE
    ) +
    ggplot2::scale_fill_manual(
      values = palette,
      breaks = legend_levels,
      limits = legend_levels,
      drop = FALSE,
      na.translate = FALSE,
      na.value = "transparent",
      name = "Incidência por\n100 mil habitantes"
    ) +
    ggplot2::ggtitle(cfg$label, subtitle = subtitle) +
    ggplot2::geom_sf(
      data = br,
      linewidth = 0.08,
      color = "grey65",
      fill = "transparent",
      show.legend = FALSE
    ) +
    ggplot2::coord_sf(
      xlim = plot_limits$xlim,
      ylim = plot_limits$ylim,
      expand = FALSE,
      clip = "off",
      datum = NA
    ) +
    map_theme() +
    ggplot2::guides(
      fill = ggplot2::guide_legend(
        title.position = "top",
        title.hjust = 0,
        ncol = 1,
        byrow = TRUE,
        label.position = "right",
        label.hjust = 0,
        override.aes = list(
          fill = unname(palette),
          color = NA,
          linewidth = 0,
          alpha = 1
        )
      )
    )
}

save_map <- function(plot, output_dir, cfg) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  output_file <- file.path(
    output_dir,
    paste0("incidence_Nacional_", cfg$slug, ".png")
  )

  grDevices::png(
    output_file,
    width = 390,
    height = 404,
    bg = "transparent",
    units = "px",
    res = 85
  )

  print(plot)
  grDevices::dev.off()

  log_msg("Saved: ", normalizePath(output_file, winslash = "/", mustWork = FALSE))
  output_file
}

run_map <- function(con, shapes, cfg, epiweek, window_weeks, output_dir) {
  log_msg(
    "[map-br] disease=", cfg$slug,
    " week=", epiweek,
    " window_weeks=", window_weeks
  )

  data <- fetch_country_data(
    con = con,
    cfg = cfg,
    epiweek = epiweek,
    window_weeks = window_weeks
  )

  log_msg("Query returned rows: ", nrow(data))

  if (nrow(data) == 0) {
    log_msg("No data found for disease=", cfg$slug, level = "WARN")
    return(invisible(NULL))
  }

  incidence <- calculate_incidence(data)
  subtitle <- format_week_label(data$SE)

  log_msg("Incidence calculated for regions: ", nrow(incidence))
  log_msg("Subtitle: ", subtitle)

  plot <- build_map(
    regions = shapes$regions,
    br = shapes$br,
    incidence = incidence,
    cfg = cfg,
    subtitle = subtitle
  )

  save_map(
    plot = plot,
    output_dir = output_dir,
    cfg = cfg
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

  requested_week <- get_env_any(c("ALERTA_MAP_BR_EPIWEEK"), "latest")
  diseases_arg <- get_env_any(c("ALERTA_MAP_BR_DISEASES"), "ALL")
  output_dir <- get_env_any(
    c("ALERTA_MAP_BR_OUTPUT_DIR"),
    file.path(repo_root, "sync_maps", "incidence_maps", "country")
  )
  window_weeks <- as.integer(get_env_any(c("ALERTA_MAP_BR_WINDOW_WEEKS"), "4"))

  if (is.na(window_weeks) || window_weeks < 1) {
    stop("Invalid ALERTA_MAP_BR_WINDOW_WEEKS.", call. = FALSE)
  }

  if (
    !identical(requested_week, "latest") &&
    !grepl("^[0-9]{6}$", requested_week)
  ) {
    stop("Invalid ALERTA_MAP_BR_EPIWEEK. Expected latest or YYYYWW.", call. = FALSE)
  }

  diseases <- parse_diseases(diseases_arg)
  configs <- purrr::map(diseases, get_disease_config)

  con <- connect_db()
  on.exit(try(DBI::dbDisconnect(con), silent = TRUE), add = TRUE)

  epiweek <- resolve_epiweek(
    con = con,
    requested_week = requested_week,
    disease_configs = configs
  )

  log_msg("Map epiweek: ", epiweek)
  log_msg("Diseases: ", paste(diseases, collapse = ", "))
  log_msg("Window weeks: ", window_weeks)
  log_msg("Output dir: ", output_dir)

  shapes <- load_shapes(repo_root)

  for (cfg in configs) {
    run_map(
      con = con,
      shapes = shapes,
      cfg = cfg,
      epiweek = epiweek,
      window_weeks = window_weeks,
      output_dir = output_dir
    )
  }

  log_msg("DONE")
}

main()