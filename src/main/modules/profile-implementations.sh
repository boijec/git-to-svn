# Path: src\main\modules\profile-implementations.sh
function runConvert() {
  for branch in $(git branch -r | grep "origin/" | grep -v 'tags/' | sed 's/ origin\///'); do
    log "" pi-conv-git-b "Converting SVN branch: ${branch} to git branch"
    git branch "${branch}" origin/"${branch}" || (log ERROR pi-conv-git-b "Failed to convert SVN branch to GIT branch" ; exit 1)
  done
  for tag in $(git branch -r | grep "tags/" | sed 's/ origin\/tags\///'); do
    log "" pi-conv-git-t "Converting SVN release tag: ${tag} to git tag"
    git tag -a -m "SVN Release Tag ${tag}" origin/tags/"${tag}" || (log ERROR pi-co-git-t "Failed to convert SVN tag to GIT tag" ; exit 1)
  done
}
function runSync() {
  echo -e "${GLOBAL_SVN_PASS}" | git svn rebase --username="${GLOBAL_SVN_USER}" || (log ERROR pi-sc-reb "Failed to preform 'git svn rebase'" ; exit 1)
}
function runPull() {
  if [ ! -f "${SVN_TO_GIT_DIR}/authors_export.txt" ]; then
    log ERROR pi-pl-authf "No authors file provided"
    exit 1
  fi
  if [ -z "${1}" ]; then
    log ERROR pi-pl-url "No SVN url provided"
    exit 1
  fi
  echo -e "${GLOBAL_SVN_PASS}" | git svn clone --username="${GLOBAL_SVN_USER}" --trunk=/trunk --branches=/branches --tags=/tags --authors-file="${SVN_TO_GIT_DIR}/authors_export.txt" "${1}" || (log ERROR pi-pl-clone "Failed to preform 'git svn clone', try executing the incantation manually: 'git svn clone --username='{{svn user}}' --trunk=/trunk --branches=/branches --tags=/tags --authors-file='${SVN_TO_GIT_DIR}/authors_export.txt' ${1}" ; exit 1)
}
function runClean() {
  for branch in $(git branch -l | grep -v 'master'); do
    log "" pi-pl-git-brm "Removing GIT branch: ${branch}"
    git branch -D "${branch}" || (log ERROR pi-pl-git-brm "Failed to remove GIT branch" ; exit 1)
  done
  for tag in $(git tag -l); do
    log "" pi-pl-git-trm "Removing GIT tag: ${tag}"
    git tag -d "${tag}" || (log ERROR pi-pl-git-trm "Failed to remove GIT tag" ; exit 1)
  done
}
function runAuthorsExport() {
  if [ -z "${1}" ]; then
    log ERROR pi-ax-url "No SVN url provided"
    exit 1
  fi
  log "" pi-ax-exp "Reading the repo logs.. this might take a while on very large repositories.. when finished we'll show you where we saved it."
  START_TIMSTAMP=$(date +%s)
  echo -e "${GLOBAL_SVN_PASS}" | svn log --quiet "${1}" | grep "^r" | awk '{print $3}' | sort | uniq > "${SVN_TO_GIT_DIR}/authors_export.txt" || (log "" pi-ax-exp "Failed to fetch SVN log, try executing the incantation manually: 'svn log --no-auth-cache --non-interactive --username {{svn user}} --password {{svn password}} --quiet ${1} | grep '^r'' | awk '{print $3}' | sort | uniq > '${SVN_TO_GIT_DIR}/authors_export.txt'" ; exit 1)
  END_TIMSTAMP=$(date +%s)
  log "Done! Export took $((END_TIMSTAMP-START_TIMSTAMP)) seconds!"
}