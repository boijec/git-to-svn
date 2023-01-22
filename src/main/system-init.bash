#-- Path: src\main\svn-to-git.bash
if [[ ! -d "${SVN_TO_GIT_DIR}" ]]; then
  log ERROR system-init-cdc "Could not find main directory in /tmp.. quitting.." ; exit 1
fi
#-- svn-credential-manager.sh
checkIfExistsOrPropmtAndGracefullyExit
loadCredentials