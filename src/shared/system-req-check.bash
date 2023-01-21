# Path: src\installer\installer-core.bash
if ! command -v uname > /dev/null ; then
  log ERROR system-req-uname "'uname' command is not available, this is not allowed.. quitting.." ; exit 1
fi
CHECK_OS=$(uname -a | grep -ic 'linux')
if [[ "${CHECK_OS}" -lt "1" ]]; then
  log ERROR system-req-os "Could not determine Linux OS through uname, quitting, immediately.." ; exit 1
fi