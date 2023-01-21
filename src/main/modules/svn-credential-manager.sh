# Path: src\main\git-to-svn.bash
function writeCredentials() {
  echo -e "${1}\n${2}" > "${SVN_TO_GIT_CREDENTIAL_FILE}" || (log ERROR svncm-ow "Could not write svn credentials to file" ; exit 1)
  log "" svncm-ow "Credentials successfully written to file"
}
function checkForCredentials() {
  if [[ -z "${GLOBAL_SVN_USER}" || -z "${GLOBAL_SVN_PASS}" ]]; then
    log ERROR svncm-c3 "No credentials loaded, can't perform action" ; exit 1
  fi
}
function removeCredentials() {
  log "" svncm-remove "Removing credential file"
  rm -f "${SVN_TO_GIT_CREDENTIAL_FILE}" || log ERROR svncm-remove "Error occurred while trying to remove credentials file, please consider removing it manually at ${SVN_TO_GIT_CREDENTIAL_FILE}" ; exit 0
}
function loadCredentials() {
  GLOBAL_SVN_USER=$(head -n 1 "${SVN_TO_GIT_CREDENTIAL_FILE}")
  GLOBAL_SVN_PASS=$(head -n 2 "${SVN_TO_GIT_CREDENTIAL_FILE}")
  log "" svncm-load "Credentials loaded"
}
function checkIfExistsOrPropmtAndGracefullyExit() {
  if [[ ! -f "${SVN_TO_GIT_CREDENTIAL_FILE}" ]]; then
    log WARN system-init-cfidc "Could not find svn credentials file, creating one.."
    touch "${SVN_TO_GIT_CREDENTIAL_FILE}" || (log ERROR svncm-init-crs "Could not create svn credentials file" ; exit 1)
    log "" system-init-crs "Credentials file created"
    printf "Please enter your SVN username: "
    read -r SVN_USER
    printf "Please enter your SVN password: "
    stty -echo
    read -r SVN_PASS
    stty echo
    echo
    writeCredentials "${SVN_USER}" "${SVN_PASS}"
    exit 0
  fi
}