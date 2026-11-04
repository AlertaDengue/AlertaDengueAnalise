# Source from a Makim bash task. Explicit process values, including empty ones,
# take precedence over deployment defaults in .env.
if [ -f .env ]; then
  declare -A _alerta_preserved=()
  while IFS= read -r _alerta_line; do
    if [[ "${_alerta_line}" =~ ^[[:space:]]*(export[[:space:]]+)?([A-Za-z_][A-Za-z_0-9]*)= ]]; then
      _alerta_name="${BASH_REMATCH[2]}"
      if [ "${!_alerta_name+x}" = x ]; then
        _alerta_preserved["${_alerta_name}"]="${!_alerta_name}"
      fi
    fi
  done < .env
  set -a
  . ./.env
  set +a
  for _alerta_name in "${!_alerta_preserved[@]}"; do
    export "${_alerta_name}=${_alerta_preserved[${_alerta_name}]}"
  done
  unset _alerta_preserved _alerta_line _alerta_name
fi
