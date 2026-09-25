selected_state_output_paths <- function(alertas_dir, report_epiweek, siglas) {
  file.path(
    alertas_dir,
    paste0("ale-", siglas, "-", report_epiweek, ".RData")
  )
}

br_output_path <- function(br_dir, report_epiweek) {
  file.path(br_dir, paste0("ale-BR-", report_epiweek, ".RData"))
}

generated_sql_paths <- function(sql_dir) {
  file.path(sql_dir, c(
    "output_dengue.sql", "output_chik.sql", "output_zika.sql"
  ))
}

clear_generated_artifacts <- function(paths) {
  removal_status <- unlink(paths)
  remaining <- paths[file.exists(paths)]
  if (removal_status != 0L || length(remaining) > 0) {
    failed <- if (length(remaining) > 0) remaining else paths
    stop(
      "Could not remove previous generated artifact(s): ",
      paste(failed, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(paths)
}

require_current_artifacts <- function(paths, label) {
  info <- file.info(paths)
  missing <- paths[is.na(info$size) | info$isdir | info$size == 0]
  if (length(missing) > 0) {
    stop(
      "Missing current-run ", label, " artifact(s): ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
  paths
}
