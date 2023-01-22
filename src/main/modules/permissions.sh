#-- Path: src\main\modules\permissions.sh
function checkIfUserHasWritePermissionsToInstallDir() {
  if [[ ! -w "${SVN_TO_GIT_DIR}" ]]; then
    log ERROR main-id-perm "FATAL! User does not have permissions to write to installation directory (this should NOT happen..)" ; exit 1
  fi
}
function checkIfUserHasReadPermissionsToCredentialsFile() {
  if [[ ! -r "${SVN_TO_GIT_CREDENTIAL_FILE}" ]]; then
    log ERROR main-crf-perm "FATAL! User does not have permissions to read credentials (this should NOT happen..)" ; exit 1
  fi
}
function checkIfUserHasWritePermissionsToCredentialsFile() {
  if [[ ! -w "${SVN_TO_GIT_CREDENTIAL_FILE}" ]]; then
    log ERROR main-crf-perm "FATAL! User does not have permissions to write credentials (this should NOT happen..)" ; exit 1
  fi
}