#-- Path: src\installer\installer-core.bash
#-- Check if the user is root
if [[ "${EUID}" -ne 0 ]]; then
  log ERROR inst-system-req-root "Installation must be run as root" ; exit 1
fi
#-- Check if the user has permissions to write to the /tmp folder
if [[ ! -w "/opt" ]]; then
  log ERROR inst-system-req-tmp "The user does not have permissions to write to /opt, installer" ; exit 1
fi
#-- Check if unzip can be used to unzip file
if ! command -v unzip > /dev/null 2>&1 ; then
  log ERROR inst-system-req-zip "The zip command is not installed on the system" ; exit 1
fi
#-- Prompt user for the user that he/she wants to install the script for
printf "Enter the user that you want to install the script for: "
read -r INSTALL_USER
#-- Check if the user exists on the system
if ! id -u "${INSTALL_USER}" > /dev/null 2>&1 ; then
  log ERROR inst-system-req-user "The user does not exist on the system" ; exit 1
fi
#-- Unload all files into temp dir in /tmp
cd "$(dirname "${0}")" || (log ERROR inst-chd-bs "Fatal, could not change directory to same level as installer" ; exit 1)
mkdir /tmp/svn-to-git-temp
cp -r ./bundle.zip /tmp/svn-to-git-temp/ || (log ERROR inst-cp-bundle "Fatal, could not copy bundle to temp" ; exit 1)
CURR_DIR=$(pwd)
cd /tmp/svn-to-git-temp || (log ERROR inst-chd-tt "Fatal, could not change directory to temp" ; exit 1)
unzip bundle.zip || (log ERROR inst-unzip "Fatal, could not unzip bundle" ; exit 1)
cd "${CURR_DIR}" || (log ERROR inst-chd-ft "Fatal, could not change directory back to same level as installer" ; exit 1)
#-- Check if the svn-to-git folder exists in /opt or create it
if [[ ! -d "${SVN_TO_GIT_DIR}" ]]; then
  mkdir "${SVN_TO_GIT_DIR}"
  log "" installer-dir-init "Created svn-to-git folder in /opt"
  #-- Creating bin folder to host the binary file
  if [[ ! -d "${SVN_TO_GIT_DIR}/bin" ]]; then
    mkdir "${SVN_TO_GIT_DIR}/bin"
  fi
fi
#-- Change directory to installer level
#-- Check if the svn-to-git binary exists in the svn-to-git folder or copy it from installation folder
if [[ ! -f "${SVN_TO_GIT_DIR}/bin/svn-to-git" ]]; then
  log "" installer-copy "Installing ${SCRIPTNAME}..."
  cp /tmp/svn-to-git-temp/target/svn-to-git "${SVN_TO_GIT_DIR}/bin/" || (log ERROR installer-copy "Could not copy svn-to-git to ${SVN_TO_GIT_DIR}" ; exit 1)
  log "" installer-executable "Adding executable permissions to svn-to-git"
fi
#-- Check if the svn-to-git command is available in the PATH
if ! command -v svn-to-git > /dev/null ; then
  log "" command-test "Could not find svn-to-git binary in PATH"
  printf "Do you want to add /usr/local/bin as symlink? (y/n) "
  read -r REGISTER_COMMAND
  if [[ "${REGISTER_COMMAND}" == "y" ]]; then
    ln -s "${SVN_TO_GIT_DIR}"/svn-to-git /usr/local/bin/svn-to-git || (log ERROR register-as-bin "Could not create symlink to svn-to-git script, try running installer with sudo" ; exit 1)
    log "" register-as-bin "Symlink created, restart bash to use 'svn-to-git' as a command"
  else
    log WARN register-as-bin "Command was not added to /usr/local/bin, use script in /tmp/svn-to-git/${SCRIPTNAME}"
  fi
fi
#-- Run cleanup of temp files
rm -rf /tmp/svn-to-git-temp
#-- Change ownership of the svn-to-git folder to the user that was specified
chown -R "${INSTALL_USER}":"${INSTALL_USER}" "${SVN_TO_GIT_DIR}"
log "" main-installer "Installation complete!"