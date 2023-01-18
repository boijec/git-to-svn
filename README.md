# SVN to GIT Migration Script
## Background
[Atlassian's SVN-to-GIT migration guide](https://www.atlassian.com/git/tutorials/migrating-overview) is a very good guide
on how to migrate your SVN repository to Git. However, it's not been kept up to date and there are (in some cases)
some very serious issues with it.

This script is an attempt at easing / alleviating some headaches while traveling down the road, less traveled.

## Usage
### Prerequisites
* Run under a Linux environment
* Install command-line tools for git (at least v2.25.1) and subversion (at least v1.13.0)
* Install "git-svn bridge" git-svn (at least v2.25.1, it most likely not installed with the git cli)

### Run
This script has six profiles, `verify`, `export_authors`, `migrate`, `convert`, `sync` and `clean`.
Each profile has its own purpose and should be run independently.
```shell
./svn-to-git.sh [verify|export_authors|migrate|convert|sync|clean] 
```
Print usage by running:
```shell
./svn-to-git.sh --help
```
### Known Issues

#### Jan 18th, 2023

The `export_authors` profile might not work properly, certain SVN repos might lock your user depending
on the authentication mapping you have configured on you SVN server.
If `export_authors` fails, I highly recommend creating the `authors.txt` file manually.
This can be done by running the incantation:
```shell
svn log {{SVN_SERVER_URL}} --quiet | grep "^r" | awk '{print $3}' | sort | uniq > ~/authors_export.txt
```
This may take a while, depending on the size of your SVN repo, but ultimately it will create a file in your
home directory called `authors_export.txt` which you can later point to when running the other script profiles.