#!/bin/bash

SCRIPTNAME=$(basename $0)
ORIGIN_DIR=$(pwd)

printUsage()
{
  echo "=========SVN-to-GIT MIGRATION SCRIPT========="
  echo "Author: Carl Boije, 2023"
  echo "Before using, consider running the 'verify' profile to verify that everything is installed correctly"
  echo "The 'convert', 'sync' and 'migrate' profiles all have input arguments, absolute paths are recommended, but relative works too."
  echo
  echo "Recommended workflow:"
  echo "'verify' that all tools are installed"
  echo "'export_authors' from SVN to a file that can be referenced later when migrating repositories"
  echo "'migrate' the remote SVN repo to a local git repo"
  echo "'convert' the SVN branches and tags into local git branches and tags"
  echo "'sync' changes made from SVN to your local GIT repo"
  echo "(optional) 'clean' your local git repo, this removes all local git branches and tags with one simple command"
  echo
  echo -e "\t./${SCRIPTNAME} verify"
  echo -e "\t./${SCRIPTNAME} export_authors [SVN_ROOT_PATH] [EXPORT_DIRECTORY]"
  echo -e "\t./${SCRIPTNAME} migrate [DESIRED_LOCATION] [PATH_TO_AUTHORS_FILE] [SVN_REPO_URL]"
  echo -e "\t./${SCRIPTNAME} convert [PATH_TO_LOCAL_GIT_REPOSITORY_ROOT]"
  echo -e "\t./${SCRIPTNAME} sync [PATH_TO_LOCAL_GIT_REPOSITORY_ROOT]"
  echo -e "\t./${SCRIPTNAME} clean [PATH_TO_LOCAL_GIT_REPOSITORY_ROOT]"
  echo
  echo "** RUNTIME ASSUMES THAT YOU'RE RUNNING UNDER A WSL 2.0 INSTANCE, OR A UNIX BASED TERMINAL **"
  echo "** RUNTIME ALSO ASSUMES THAT YOU HAVE A DEFAULT SVN USER CACHED THROUGH GIT SVN AND HAVE ACCEPTED THE SERVER CERT (if the migrate profile doesn't work, you can copy the steps from the script and do it manually) **"
}

checkSoftwareVersions()
{
  if ! command -v uname > /dev/null ; then
    log "'uname' command is not available, this is not allowed.. quitting.."
    exit 1;
  fi
  CHECK_OS=$(uname -a | grep -i 'linux' | wc -l)
  if [[ "$CHECK_OS" -lt "1" ]]; then\
    log "Could not determine Linux OS through uname, quitting, immediately.."
    exit 1;
  else
    log "uname check, passed.."
  fi

  FAILED_VALIDATION="0"
  log "Running command redundancy..."
  
  if ! command -v svn > /dev/null ; then
    log "SVN command run, failed.."
    FAILED_VALIDATION=1;
  fi

  if ! command -v git > /dev/null ; then
    log "GIT command run, failed"
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
    echo -e "GIT version not compatible! Please install git version ${MINIMUM_GIT_VERSION} or higher".
    FAILED_VALIDATION=1;
  else
    echo -e "GIT> ${GIT_VERSION}.. OK!"
  fi

  if [[ "$SVN_VERSION" < "$MINIMUM_SVN_VERSION" ]]; then
    echo -e "SVN version not compatible! Please install svn version ${MINIMUM_SVN_VERSION} or higher"
    FAILED_VALIDATION=1;
  else
    echo -e "SVN> ${SVN_VERSION}.. OK!"
  fi

  if [[ "$GIT_SVN_VERSION" < "$MINIMUM_GITSVN_VERSION" ]]; then
    echo -e "GIT-SVN version not compatible! Please install git-svn version ${MINIMUM_GITSVN_VERSION} or higher!"
    FAILED_VALIDATION=1;
  else
    echo -e "GIT-SVN> ${GIT_SVN_VERSION}.. OK!"
  fi

  quitIfFailed $FAILED_VALIDATION

  log "Verification passed, all tools are installed and compatible!"
}

quitIfFailed()
{
  if [[ "$1" -eq "1" ]]; then
    log "Something went wrong, maybe the git, svn or git-svn weren't installed correctly? Try re-installing, and trying running './${SCRIPTNAME} verify' again."
    exit $1;
  fi
}

checkDesiredFolder()
{
  if [ ! -d "$1" ]; then
    log "INPUT_ERROR: Folder is not defined / Path does not lead to a valid directory"
    exit 1;
  fi

  if [ ! -d "$1/.git" ]; then
    log "VALIDATION_ERROR: Directory is not a valid git repo"
    exit 1;
  fi
}


runConvert()
{
  for branch in `git branch -r | grep "origin/" | grep -v 'tags/' | sed 's/ origin\///'`; do
    log "Converting SVN branch: ${branch} to git branch"
    git branch $branch origin/$branch | exit 1
  done

  for tag in `git branch -r | grep "tags/" | sed 's/ origin\/tags\///'`; do
    log "Converting SVN release tag: ${tag} to git tag"
    git tag -a -m "SVN Release Tag" $tag origin/tags/$tag | exit 1
  done
}

runSync()
{
  echo -e "${SVN_PASS}" | git svn rebase
}

runPull()
{
  if [ ! -f $1 ]; then
    log "INPUT_ERROR: No authors file provided"
    exit 1;
  fi

  if [ -z "$2" ]; then
    log "INPUT_ERROR: No SVN url provided"
    exit 1;
  fi

  echo -e "${SVN_PASS}" | git svn clone --trunk=/trunk --branches=/branches --tags=/tags --authors-file=$1 $2
}

runClean()
{
  for branch in `git branch -l | grep -v 'master'`; do
    log "Removing GIT branch: ${branch}"
    git branch -D $branch | exit 1
  done

  for tag in `git tag -l`; do
    log "Removing GIT tag: ${tag}"
    git tag -d $tag | exit 1
  done
}

runAuthorsExport()
{
  if [ -z "$1" ]; then
    log "INPUT_ERROR: No SVN url provided"
    exit 1;
  fi

  if [ ! -d "$2" ]; then
    log "INPUT_ERROR: Folder is not defined / Path does not lead to a valid directory"
    exit 1;
  fi

  log "Reading the repo logs.. this might take a while on very large repositories.. when finished we'll show you where we saved it."
  START_TIMSTAMP=$(date +%s)
  `svn log --username ${SVN_USER} --password ${SVN_PASS} --quiet $1 | grep "^r" | awk '{print $3}' | sort | uniq > $2/authors_export.txt` | log "Failed to fetch SVN log" && exit 1;
  END_TIMSTAMP=$(date +%s)
  log "Done! Export took $(($END_TIMSTAMP-$START_TIMSTAMP)) seconds!"
}

log()
{
  echo -e "$(date) $SCRIPTNAME: $1"
}

case "$1" in
  verify)
    checkSoftwareVersions
    exit 0;
  ;;
  convert)
    checkDesiredFolder $2
    cd $2
    runConvert
    cd $ORIGIN_DIR
    exit 0;
  ;;
  sync)
    checkDesiredFolder $2
    printf "SVN password for your default user: "
    read SVN_PASS
    cd $2
    runSync
    cd $ORIGIN_DIR
    exit 0;
  ;;
  clean)
    checkDesiredFolder $2
    printf "This will remove all local branches and tags, this action is non-reversible, continue Yes(Y), No(n): "
    read CONFIRMATION_OF_DELETION
    if [[ "$CONFIRMATION_OF_DELETION" != "Y" ]]; then
      log "Clean was not performed"
      exit 0;
    fi
    cd $2
    runClean
    cd $ORIGIN_DIR
    exit 0;
  ;;
  migrate)
    printf "SVN password for your default user: "
    read SVN_PASS
    cd $2
    runPull $3 $4
    cd $ORIGIN_DIR
    exit 0;
  ;;
  export_authors)
    printf "SVN username: "
    read SVN_USER
    printf "SVN password for ${SVN_USER}: "
    read SVN_PASS
    runAuthorsExport $2 $3
    ls -la $3
    exit 0;
  ;;
  --help)
    printUsage
    exit 0;
  ;;
  *)
    log "Profile does not exist, run './${SCRIPTNAME} --help' for more information"
    exit 0;
  ;;
esac