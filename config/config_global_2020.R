# ====================================================
# Arquivo de configuracao global do Alerta Dengue 2020
# ====================================================

pkgs <- c(
  "parallel",
  "foreign", "tidyverse", "forecast", "RPostgreSQL", "xtable",
  "zoo", "assertthat", "DBI",
  "futile.logger", "lubridate", "grid",
  "cgwtools", "fs", "miceadds", "AlertTools"
)

missing_pkgs <- pkgs[!vapply(
  pkgs,
  requireNamespace,
  logical(1),
  quietly = TRUE
)]

auto_install <- identical(
  Sys.getenv("ALERTADENGUE_AUTO_INSTALL_PKGS", unset = "false"),
  "true"
)

if (length(missing_pkgs) > 0) {
  message(
    "[config] Pacotes ausentes: ",
    paste(missing_pkgs, collapse = ", ")
  )

  if (auto_install) {
    install.packages(missing_pkgs, repos = "https://cran.r-project.org")
  } else {
    stop(
      paste0(
        "Pacotes R ausentes: ",
        paste(missing_pkgs, collapse = ", "),
        "\n",
        "Instale manualmente ou rode com ",
        "ALERTADENGUE_AUTO_INSTALL_PKGS=true."
      ),
      call. = FALSE
    )
  }
}

invisible(lapply(
  pkgs,
  function(pkg) {
    suppressPackageStartupMessages(
      library(pkg, character.only = TRUE, quietly = TRUE)
    )
  }
))

has_inla <- FALSE
if (requireNamespace("INLA", quietly = TRUE)) {
  suppressPackageStartupMessages(library(INLA))
  has_inla <- exists("inla", mode = "function")
}

if (!has_inla) {
  message("[config] INLA/inla() indisponível. Nowcasting bayesiano desativado.")
}

basedir <- getwd()
print(basedir)

estados_Infodengue <- data.frame(
  estado = c(
    "Acre", "Amazonas", "Amapá", "Pará", "Rondônia", "Roraima", "Tocantins",
    "Alagoas", "Bahia", "Ceará", "Maranhão", "Piauí", "Pernambuco",
    "Paraíba", "Rio Grande do Norte", "Sergipe",
    "Goiás", "Mato Grosso do Sul", "Distrito Federal",
    "Espírito Santo", "Minas Gerais", "Rio de Janeiro", "São Paulo",
    "Paraná", "Rio Grande do Sul", "Santa Catarina", "Mato Grosso"
  ),
  sigla = c(
    "AC", "AM", "AP", "PA", "RO", "RR", "TO",
    "AL", "BA", "CE", "MA", "PI", "PE", "PB", "RN", "SE",
    "GO", "MS", "DF",
    "ES", "MG", "RJ", "SP",
    "PR", "RS", "SC", "MT"
  ),
  dengue = TRUE,
  chik = TRUE,
  zika = FALSE
)
