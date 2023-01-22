#-- Path: src\main\module\options-parser.sh
function parseOptions() {
  INPUT_ARGS=("${@}")
  for i in "${!INPUT_ARGS[@]}"; do
    #-- If argument doesn't start with '--' or '-' then it's not an option, so skip it
    if [[ ! "${INPUT_ARGS[i]}" =~ ^- ]]; then
      continue
    fi
    case "${INPUT_ARGS[i]}" in
      --svn-url)
        checkIfNextArgumentIsValid "${INPUT_ARGS[i+1]}"
        SVN_URL="${INPUT_ARGS[i+1]}"
      ;;
      --target-dir)
        checkIfNextArgumentIsValid "${INPUT_ARGS[i+1]}"
        TARGET_DIR="${INPUT_ARGS[i+1]}"
      ;;
      *)
        log ERROR main "Unknown option '${INPUT_ARGS[i]}'" ; exit 1
      ;;
    esac
  done
}