# =============================================================================
# Alerta Dengue Nacional (executável via Rscript + Makim)
# =============================================================================

options(stringsAsFactors = FALSE)

# Logger padronizado para saída em stdout (útil para execução via Makim/CI).
log_msg <- function(..., level = "INFO") {
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  msg <- paste0(...)
  cat(sprintf("[%s] [%s] %s\n", ts, level, msg))
}

# Localiza a raiz do repositório a partir de um diretório inicial, subindo
# alguns níveis e validando a existência de arquivos-chave do projeto.
find_repo_root <- function(start_dir) {
  cur <- normalizePath(start_dir, winslash = "/", mustWork = FALSE)
  for (i in 1:8) {
    has_main <- file.exists(file.path(cur, "main", "main_BR.R"))
    has_cfg1 <- file.exists(file.path(cur, "config", "config_global_2020.R"))
    has_cfg2 <- file.exists(
      file.path(cur, "AlertaDengueAnalise", "config", "config_global_2020.R")
    )
    if (has_main && (has_cfg1 || has_cfg2)) {
      return(cur)
    }
    parent <- normalizePath(
      file.path(cur, ".."),
      winslash = "/",
      mustWork = FALSE
    )
    if (identical(parent, cur)) break
    cur <- parent
  }
  stop("Could not locate repo root from: ", start_dir, call. = FALSE)
}

# Obtém a primeira variável de ambiente disponível dentre os nomes fornecidos.
get_env_any <- function(names, default = NULL) {
  for (nm in names) {
    val <- Sys.getenv(nm, unset = "")
    if (nzchar(val)) return(val)
  }
  default
}

# Determina o diretório do script em execução para resolução consistente
# de paths relativos e descoberta da raiz do repositório.
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

# Carrega a configuração global do pipeline (lista de estados, funções, libs).
cfg_path <- if (file.exists(file.path(repo_root, "config",
                                     "config_global_2020.R"))) {
  file.path(repo_root, "config", "config_global_2020.R")
} else {
  file.path(repo_root, "AlertaDengueAnalise", "config", "config_global_2020.R")
}
log_msg("Loading config: ", cfg_path)
source(cfg_path)

# Garante disponibilidade de mclapply (muitas rotinas do pipeline usam paralelismo).
if (!exists("mclapply", mode = "function")) {
  if (!requireNamespace("parallel", quietly = TRUE)) {
    stop("Missing base R package 'parallel'.", call. = FALSE)
  }
  mclapply <- parallel::mclapply
  log_msg("Enabled parallel::mclapply()")
}

# Semana epidemiológica de referência (YYYYWW), fornecida via ambiente (Makim).
data_relatorio <- as.integer(
  get_env_any(c("ALERTA_DATA_RELATORIO", "DATA_RELATORIO"), default = NA)
)
if (is.na(data_relatorio)) {
  stop("Missing ALERTA_DATA_RELATORIO (expected YYYYWW).", call. = FALSE)
}
log_msg("Week (data_relatorio): ", data_relatorio)

# Data de término do período do relatório (a partir da SE informada).
dia_relatorio <- seqSE(data_relatorio, data_relatorio)$Termino
log_msg("Report end date (dia_relatorio): ", as.character(dia_relatorio))

# Diretórios de saída:
# - alertas_dir: RData por estado/semana
# - sql_dir: scripts SQL gerados
# - br_dir: RData agregado nacional (BR)
out_base <- get_env_any(
  c("ALERTA_OUT_DIR"),
  default = file.path(repo_root, "main")
)
alertas_dir <- file.path(out_base, "alertas", as.character(data_relatorio))
sql_dir <- file.path(out_base, "sql")
br_dir <- file.path(out_base, "alertas", "BR")

dir.create(alertas_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(sql_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(br_dir, recursive = TRUE, showWarnings = FALSE)

log_msg("Outputs:")
log_msg(" - alertas_dir: ", alertas_dir)
log_msg(" - sql_dir:     ", sql_dir)
log_msg(" - br_dir:      ", br_dir)

# Parâmetros de conexão ao Postgres (obtidos via ambiente/.env).
db_host <- get_env_any(c("ALERTA_DB_HOST", "DB_HOST"), default = "127.0.0.1")
db_port <- as.integer(get_env_any(c("ALERTA_DB_PORT", "DB_PORT"),
                                  default = "5432"))
db_name <- get_env_any(c("ALERTA_DB_NAME", "DB_NAME"), default = "dengue")
db_user <- get_env_any(c("ALERTA_DB_USER", "DB_USER"), default = "")
db_pass <- get_env_any(c("ALERTA_DB_PASSWORD", "DB_PASSWORD"), default = "")

if (!nzchar(db_user) || !nzchar(db_pass)) {
  stop("Missing DB_USER/DB_PASSWORD in env (.env).", call. = FALSE)
}

log_msg("Connecting DB: host=", db_host, " port=", db_port, " dbname=", db_name,
        " user=", db_user)

# Abre conexão com o banco (usada por rotinas do pipeline para parâmetros e dados).
con <- DBI::dbConnect(
  drv = RPostgreSQL::PostgreSQL(),
  dbname = db_name,
  host = db_host,
  port = db_port,
  user = db_user,
  password = db_pass
)
on.exit(try(DBI::dbDisconnect(con), silent = TRUE), add = TRUE)

log_msg("DB connected OK")

# Publicação opcional dos .RData via scp (independente do banco ser local/remoto).
do_scp <- tolower(get_env_any(c("ALERTA_DO_SCP"), default = "0")) %in%
  c("1", "true", "yes", "y")
scp_port <- get_env_any(c("ALERTA_SCP_PORT"), default = "22")
scp_target <- get_env_any(
  c("ALERTA_SCP_TARGET"),
  default = "administrador@65.21.204.98:/Storage/infodengue_data/alertasRData/"
)

t1 <- Sys.time()
n_states <- nrow(estados_Infodengue)

log_msg("Starting pipeline for ", n_states, " state row(s)")

# Execução do pipeline por linha da configuração de estados.
for (i in seq_len(n_states)) {
  row_i <- estados_Infodengue[i, ]
  estado <- as.character(row_i$estado)
  sig <- as.character(row_i$sigla)

  log_msg(sprintf("[state] %d/%d %s (%s)", i, n_states, estado, sig))

  # Arquivo de saída por estado: lista 'res' contendo 'ale.*' e 'restab.*'.
  nomeRData <- paste0("ale-", sig, "-", data_relatorio, ".RData")
  out_rdata <- file.path(alertas_dir, nomeRData)

  # Municípios (geocódigos) utilizados para cálculo do alerta estadual.
  cidades <- getCidades(uf = estado)[, "municipio_geocodigo"]
  if (length(cidades) == 0) {
    stop("No cities returned for state: ", estado, call. = FALSE)
  }

  res <- list()

  # Dengue
  if (isTRUE(row_i$dengue)) {
    log_msg(" - dengue: running pipe_infodengue")
    res[["ale.den"]] <- pipe_infodengue(
      cidades,
      cid10 = "A90",
      nowcasting = "none",
      finalday = dia_relatorio,
      narule = "arima",
      iniSE = 201001,
      dataini = "sinpri",
      completetail = 0
    )
    res[["restab.den"]] <- tabela_historico(
      res[["ale.den"]],
      iniSE = data_relatorio - 100
    )
  } else {
    log_msg(" - dengue: skipped")
  }

  # Chikungunya
  if (isTRUE(row_i$chik)) {
    log_msg(" - chik: running pipe_infodengue")
    res[["ale.chik"]] <- pipe_infodengue(
      cidades,
      cid10 = "A92",
      nowcasting = "bayesian",
      finalday = dia_relatorio,
      narule = "arima",
      iniSE = 201001,
      dataini = "sinpri",
      completetail = 0
    )
    res[["restab.chik"]] <- tabela_historico(
      res[["ale.chik"]],
      iniSE = data_relatorio - 100
    )
  } else {
    log_msg(" - chik: skipped")
  }

  # Zika
  if (isTRUE(row_i$zika)) {
    log_msg(" - zika: running pipe_infodengue")
    res[["ale.zika"]] <- pipe_infodengue(
      cidades,
      cid10 = "A92.8",
      nowcasting = "bayesian",
      finalday = dia_relatorio,
      narule = "arima",
      iniSE = 201001,
      dataini = "sinpri",
      completetail = 0
    )
    res[["restab.zika"]] <- tabela_historico(
      res[["ale.zika"]],
      iniSE = data_relatorio - 100
    )
  } else {
    log_msg(" - zika: skipped")
  }

  save(res, file = out_rdata)
  log_msg("Saved: ", out_rdata)

  if (do_scp) {
    cmd <- paste(
      "scp -P",
      shQuote(scp_port),
      shQuote(out_rdata),
      shQuote(scp_target)
    )
    log_msg("SCP: ", cmd)
    system(cmd)
  }
}

t2 <- Sys.time()
log_msg("Pipeline loop finished. Elapsed: ", as.character(t2 - t1))

# Agregação dos resultados salvos em alertas_dir para geração dos outputs finais.
log_msg("Loading .RData outputs from: ", alertas_dir)
file_paths <- list.files(alertas_dir, full.names = TRUE, pattern = "\\.RData$")
if (length(file_paths) == 0) {
  stop("No .RData files found in: ", alertas_dir, call. = FALSE)
}

# Carrega cada arquivo em ambiente isolado e coleta o objeto 'res'.
res_list <- vector("list", length(file_paths))
for (k in seq_along(file_paths)) {
  env_k <- new.env(parent = emptyenv())
  load(file_paths[k], envir = env_k)
  if (!exists("res", envir = env_k, inherits = FALSE)) {
    stop("Missing object 'res' inside: ", file_paths[k], call. = FALSE)
  }
  res_list[[k]] <- env_k$res
}
log_msg("Loaded ", length(res_list), " result file(s)")

# Consolida as tabelas históricas ('restab.*') dos estados.
combine_restab <- function(key) {
  parts <- lapply(res_list, function(r) r[[key]])
  parts <- Filter(Negate(is.null), parts)
  if (length(parts) == 0) return(NULL)

  dfs <- lapply(parts, function(x) {
    if (is.list(x) && !is.data.frame(x)) {
      dplyr::bind_rows(x)
    } else {
      x
    }
  })
  dplyr::bind_rows(dfs)
}

restab_den <- combine_restab("restab.den")
restab_chik <- combine_restab("restab.chik")
restab_zika <- combine_restab("restab.zika")

# Ajuste de segurança para valores extremos de 'casos_est_max'.
cap_max <- function(df) {
  if (is.null(df)) return(NULL)
  if ("casos_est_max" %in% names(df)) {
    df$casos_est_max[df$casos_est_max > 10000] <- NA
  }
  df
}

restab_den <- cap_max(restab_den)
restab_chik <- cap_max(restab_chik)
restab_zika <- cap_max(restab_zika)

# Geração dos arquivos SQL por agravo (quando houver dados).
if (!is.null(restab_den)) {
  out_sql <- file.path(sql_dir, "output_dengue.sql")
  log_msg("Writing SQL dengue: ", out_sql)
  write_alerta(restab_den, writetofile = TRUE, arq = out_sql)
} else {
  log_msg("No dengue restab found. Skipping dengue SQL.", level = "WARN")
}

if (!is.null(restab_chik)) {
  out_sql <- file.path(sql_dir, "output_chik.sql")
  log_msg("Writing SQL chik: ", out_sql)
  write_alerta(restab_chik, writetofile = TRUE, arq = out_sql)
} else {
  log_msg("No chik restab found. Skipping chik SQL.", level = "WARN")
}

if (!is.null(restab_zika)) {
  out_sql <- file.path(sql_dir, "output_zika.sql")
  log_msg("Writing SQL zika: ", out_sql)
  write_alerta(restab_zika, writetofile = TRUE, arq = out_sql)
} else {
  log_msg("No zika restab found. Skipping zika SQL.", level = "WARN")
}

# Consolida as estruturas 'ale.*' para produzir um RData agregado nacional.
collect_ale <- function(key) {
  parts <- lapply(res_list, function(r) r[[key]])
  parts <- Filter(Negate(is.null), parts)
  if (length(parts) == 0) return(NULL)

  rows <- lapply(parts, function(x) {
    tr <- transpose(x)
    data <- dplyr::bind_rows(tr[[1]])
    idx <- dplyr::bind_rows(tr[[2]])
    cbind(data, idx)
  })
  dplyr::bind_rows(rows)
}

ale_den <- collect_ale("ale.den")
ale_chik <- collect_ale("ale.chik")
ale_zika <- collect_ale("ale.zika")

d <- NULL
if (!is.null(ale_den) && !is.null(ale_chik)) {
  d <- rbind.data.frame(ale_den, ale_chik)
} else if (!is.null(ale_den)) {
  d <- ale_den
} else if (!is.null(ale_chik)) {
  d <- ale_chik
} else if (!is.null(ale_zika)) {
  d <- ale_zika
}

if (is.null(d)) {
  log_msg("No 'ale.*' data found. Skipping BR RData.", level = "WARN")
} else {
  out_br <- file.path(br_dir, paste0("ale-BR-", data_relatorio, ".RData"))
  log_msg("Saving BR RData: ", out_br)
  save(d, file = out_br)
}

log_msg("DONE")
