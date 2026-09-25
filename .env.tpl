# PostgreSQL connection (substitute from the deployment environment)
ALERTA_DB_HOST=${ALERTA_DB_HOST}
ALERTA_DB_PORT=${ALERTA_DB_PORT}
ALERTA_DB_NAME=${ALERTA_DB_NAME}
ALERTA_DB_USER=${ALERTA_DB_USER}
ALERTA_DB_PASSWORD=${ALERTA_DB_PASSWORD}

# Persistent container outputs on the host
ALERTA_OUTPUT_DIR=${ALERTA_OUTPUT_DIR}

# Optional host/native execution output directory.
# Container execution overrides ALERTA_OUT_DIR with /outputs.
ALERTA_OUT_DIR=${ALERTA_OUT_DIR}

# Optional SCP publishing
ALERTA_DO_SCP=${ALERTA_DO_SCP}
ALERTA_SCP_ENDPOINT=${ALERTA_SCP_ENDPOINT}
ALERTA_SCP_PATH=${ALERTA_SCP_PATH}
