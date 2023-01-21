# Path: src\main\svn-to-git.bash
if [[ ! -d "${SVN_TO_GIT_DIR}" ]]; then
  log ERROR system-init-cdc "Could not find temp folder in /tmp" ; exit 1
fi
# Referring to the credential module to handle the load and keeping of credentials
checkIfExistsOrPropmtAndGracefullyExit
loadCredentials