#-- Path: src\main\main.bash
#-- Loop through all the arguments and check if option '--svn-url' is present
parseOptions "${@}"
case "$1" in
  verify)
    checkSoftwareVersions
    exit 0;
  ;;
  convert)
    checkIfDesiredFolderExistsAndIsRepo "${2}"
    cd "${2}" || (log ERROR main-convert "Unexpected error" ; exit 1)
    runConvert
    cd "${ORIGIN_DIR}" || (log ERROR main-convert "Unexpected error" ; exit 1)
    exit 0;
  ;;
  sync)
    checkIfDesiredFolderExistsAndIsRepo "${2}"
    checkForCredentials
    cd "${2}" || (log ERROR main-sync "Unexpected error" ; exit 1)
    runSync
    cd "${ORIGIN_DIR}" || (log ERROR main-sync "Unexpected error" ; exit 1)
    exit 0;
  ;;
  clean)
    checkIfDesiredFolderExistsAndIsRepo "${2}"
    printf "This will remove all local branches and tags, this action is non-reversible, continue Yes(Y), No(n): "
    read -r CONFIRMATION_OF_DELETION
    if [[ "${CONFIRMATION_OF_DELETION}" != "Y" ]]; then
      log "" main-clean "Clean was not performed"
      exit 0;
    fi
    cd "${2}" || (log ERROR main-clean "Unexpected error" ; exit 1)
    runClean
    cd "${ORIGIN_DIR}" || (log ERROR main-clean "Unexpected error" ; exit 1)
    exit 0;
  ;;
  migrate)
    checkIfDesiredFolderExists "${2}"
    checkForCredentials
    cd "${2}" || (log ERROR main-migrate "Unexpected error" ; exit 1)
    runPull "${3}"
    cd "${ORIGIN_DIR}" || (log ERROR main-migrate "Unexpected error" ; exit 1)
    exit 0;
  ;;
  export-authors)
    checkForCredentials
    runAuthorsExport "${2}"
    ls -la "${3}"
    exit 0;
  ;;
#-- create-incantation)
#--    checkForCredentials
#--    exit 0;
#--  ;;
  help)
    printUsage
    exit 0;
  ;;
  *)
    log "" main "Profile does not exist, run './${SCRIPTNAME} --help' for more information"
    exit 0;
  ;;
esac