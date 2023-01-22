#-- Path: src\main\git-to-svn.bash
#-- Replacing the contents of the credential file with the new credentials
function writeCredentials() {
  checkIfUserHasWritePermissionsToCredentialsFile
  echo -e "${1}\n${2}" > "${SVN_TO_GIT_CREDENTIAL_FILE}" || (log ERROR svncm-ow "Could not write svn credentials to file" ; exit 1)
  log "" svncm-ow "Credentials successfully written to file"
}
#-- Check if the GLOBAL_SVN_USER GLOBAL_SVN_PASS variables are empty, indicating that the program has not loaded the credentials into memory
function checkForCredentials() {
  if [[ -z "${GLOBAL_SVN_USER}" || -z "${GLOBAL_SVN_PASS}" ]]; then
    log ERROR svncm-c3 "No credentials loaded, can't perform action" ; exit 1
  fi
}
#-- Removal of the credential file
function removeCredentials() {
  checkIfUserHasWritePermissionsToCredentialsFile
  log "" svncm-remove "Removing credential file"
  rm -f "${SVN_TO_GIT_CREDENTIAL_FILE}" || log ERROR svncm-remove "Error occurred while trying to remove credentials file, please consider removing it manually at ${SVN_TO_GIT_CREDENTIAL_FILE}" ; exit 0
}
#-- Loading the function into GLOBALS (This runs on every startup)
function loadCredentials() {
  checkIfUserHasReadPermissionsToCredentialsFile
  GLOBAL_SVN_USER=$(head -n 1 "${SVN_TO_GIT_CREDENTIAL_FILE}")
  GLOBAL_SVN_PASS=$(head -n 2 "${SVN_TO_GIT_CREDENTIAL_FILE}")
  log "" svncm-load "Credentials loaded"
}
#-- Checks if the credential file exists, if not, it prompts the user for the credentials and writes them to the file
function checkIfExistsOrPropmtAndGracefullyExit() {
  #-- Checking if the credential file exists
  if [[ ! -f "${SVN_TO_GIT_CREDENTIAL_FILE}" ]]; then
    checkIfUserHasWritePermissionsToInstallDir
    log WARN system-init-cfidc "Could not find svn credentials file, creating one.."
    touch "${SVN_TO_GIT_CREDENTIAL_FILE}" || (log ERROR svncm-init-crs "Could not create svn credentials file" ; exit 1)
    #-- Double-checking if user has permissions to write to the svn-to-git dir
    checkIfUserHasWritePermissionsToCredentialsFile
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