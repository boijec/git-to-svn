#-- Path: src\main\modules\git.sh
function checkSoftwareVersions() {
  FAILED_VALIDATION="0"
  log "" chs-commands "Running command redundancy..."
  if ! command -v svn > /dev/null ; then
    log ERROR chs-commands "SVN command run, failed.."
    FAILED_VALIDATION=1;
  fi
  if ! command -v git > /dev/null ; then
    log ERROR chs-commands "GIT command run, failed"
    FAILED_VALIDATION=1;
  fi
  quitIfFailed $FAILED_VALIDATION
  GIT_VERSION=$(git --version | awk '{ print $3 }')
  MINIMUM_GIT_VERSION="2.25.1"
  SVN_VERSION=$(svn --version | awk '{ print $3; exit }')
  MINIMUM_SVN_VERSION="1.13.0"
  GIT_SVN_VERSION=$(git svn --version | awk '{ print $3 }')
  MINIMUM_GITSVN_VERSION="2.25.1"
  if [[ "$GIT_VERSION" < "$MINIMUM_GIT_VERSION" ]]; then
    log ERROR chs-commands "GIT version not compatible! Please install git version ${MINIMUM_GIT_VERSION} or higher".
    FAILED_VALIDATION=1;
  else
    log "" chs-commands "GIT> ${GIT_VERSION}.. OK!"
  fi
  if [[ "$SVN_VERSION" < "$MINIMUM_SVN_VERSION" ]]; then
    log ERROR chs-commands "SVN version not compatible! Please install svn version ${MINIMUM_SVN_VERSION} or higher"
    FAILED_VALIDATION=1;
  else
    log "" chs-commands "SVN> ${SVN_VERSION}.. OK!"
  fi
  if [[ "$GIT_SVN_VERSION" < "$MINIMUM_GITSVN_VERSION" ]]; then
    log ERROR chs-commands "GIT-SVN version not compatible! Please install git-svn version ${MINIMUM_GITSVN_VERSION} or higher!"
    FAILED_VALIDATION=1;
  else
    log "" chs-commands "GIT-SVN> ${GIT_SVN_VERSION}.. OK!"
  fi
  quitIfFailed $FAILED_VALIDATION
  log "" chs-commands "Verification passed, all tools are installed and compatible!"
}
function quitIfFailed() {
  if [[ "${1}" -eq "1" ]]; then
    log ERROR chs-commands-cq "Something went wrong, maybe the git, svn or git-svn weren't installed correctly? Try re-installing, and trying running './${SCRIPTNAME} verify' again."
    exit "${1}";
  fi
}
function checkIfDesiredFolderIsRepo() {
  if [ ! -d "${1}/.git" ]; then
    log ERROR chs-dir-r "Directory is not a valid git repo"
    exit 1;
  fi
}
function checkIfDesiredFolderExists() {
  if [ ! -d "$1" ]; then
    log ERROR chs-dir-e "Folder is not defined / Path does not lead to a valid directory"
    exit 1;
  fi
}
function checkIfDesiredFolderExistsAndIsRepo() {
  checkIfDesiredFolderExists "${1}"
  checkIfDesiredFolderIsRepo "${1}"
}
#-- Checking and balancing input arguments
function checkIfNextArgumentIsValid() {
  if [[ -z "${INPUT_ARGS[i+1]}" || "${INPUT_ARGS[i+1]}" =~ ^- ]]; then
    log ERROR main "Option '${INPUT_ARGS[i]}' is missing a value" ; exit 1
  fi
}
function checkIfSvnRepoIsDefined() {
  if [[ -z "${SVN_REPO}" ]]; then
    log ERROR main "SVN repo is not defined, please define it in the config file" ; exit 1
  fi
}
function checkIfSvnRepoIsReachable() {
  if ! svn info "${SVN_REPO}" > /dev/null 2>&1; then
    log ERROR main "SVN repo is not reachable, please check the URL" ; exit 1
  fi
}
function checkIfSvnRepoIsReachableAndDefined() {
  checkIfSvnRepoIsDefined
  checkIfSvnRepoIsReachable
}
function checkIfTargetDirIsDefined() {
  if [[ -z "${TARGET_DIR}" ]]; then
    log ERROR main "Target directory is not defined, please define it in the config file" ; exit 1
  fi
}
#-- !Checking and balancing input arguments!