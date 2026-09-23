# PostgreSQL connection
ALERTA_DB_HOST=postgres
ALERTA_DB_PORT=5432
ALERTA_DB_NAME=dengue
ALERTA_DB_USER=CHANGE_ME
ALERTA_DB_PASSWORD=CHANGE_ME

# Persistent container outputs on the host
ALERTA_OUTPUT_DIR=./artifacts

# Optional host/native execution output directory.
# Container execution overrides ALERTA_OUT_DIR with /outputs.
ALERTA_OUT_DIR=

# Optional SCP publishing
ALERTA_DO_SCP=false
ALERTA_SCP_ENDPOINT=
ALERTA_SCP_PATH=
