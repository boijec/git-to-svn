# Path: src\installer\installer-core.bash
if [[ ! -d "${SVN_TO_GIT_DIR}" ]]; then
  mkdir -p "${SVN_TO_GIT_DIR}" || (log "" installer-dir-init "Could not create temp folder in /tmp" ; exit 1)
  log "" installer-dir-init "Created svn-to-git folder in /tmp"
fi
if [[ ! -f "${SVN_TO_GIT_DIR}/svn-to-git.sh" ]]; then
  log "" installer-copy "Installing svn-to-git.sh to ${SVN_TO_GIT_DIR}"
  cp svn-to-git.sh "${SVN_TO_GIT_DIR}" || (log ERROR installer-copy "Could not copy svn-to-git.sh to ${SVN_TO_GIT_DIR}" ; exit 1)
  log "" installer-executable "Adding executable permissions to svn-to-git.sh"
  chmod +x "${SVN_TO_GIT_DIR}/svn-to-git.sh"
fi
if ! command -v svn-to-git > /dev/null ; then
  log "" command-test "Could not find svn-to-git binary in PATH"
  printf "Do you want to register script as a command? This can be manually (y/n) "
  read -r REGISTER_COMMAND
  if [[ "${REGISTER_COMMAND}" == "y" ]]; then
    ln -s /tmp/svn-to-git/svn-to-git.sh /usr/local/bin/svn-to-git || (log ERROR register-as-bin "Could not create symlink to svn-to-git script, try running installer with sudo" ; exit 1)
    log "" register-as-bin "Symlink created, restart bash to use svn-to-git as a command"
  fi
fi