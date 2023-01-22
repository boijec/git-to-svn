#-- Path: src\installer\installer-core.bash
#-- Determine if os type is supported
if [[ "${OSTYPE}" != "linux-gnu" ]]; then
  log ERROR system-req-os "Script has to be run in a linux environment, quitting immediately.." ; exit 1
fi