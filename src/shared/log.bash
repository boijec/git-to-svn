#-- Path: src\main\log.bash
function log() {
  if [[ -z "${1}" ]]; then
    LEVEL="INFO"
  else
    LEVEL="${1}"
  fi
  if [[ -z "${2}" ]]; then
    SEQUENCE="main"
  else
    SEQUENCE="${2}"
  fi
  echo -e "$(date) [${SCRIPTNAME}] ${LEVEL} (${SEQUENCE}) : ${3}"
}