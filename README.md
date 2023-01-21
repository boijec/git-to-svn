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
* Install "git-svn bridge" git-svn (at least v2.25.1, it's most likely not installed with the git cli)

### Installation
The Makefile builds an installer that you can run to install the script as a command-line tool as well
as making sure that the `/tmp` folder for the script is created.

### Run
On your first run, you'll be asked to enter SVN login credentials. These will be stored in a file in the `/tmp` directory.<br>
On each run, this file will be read and the credentials will be used to authenticate with the SVN server.<br>
The script has six profiles, `verify`, `export_authors`, `migrate`, `convert`, `sync` and `clean`.
Each profile has its own purpose and should be run independently.
```shell
./svn-to-git.sh [verify|export_authors|migrate|convert|sync|clean] 
```
Print usage by running:
```shell
./svn-to-git.sh --help
```
### Known Issues

#### Jan 21st, 2023

The `export_authors` profile might not work properly, the SVN log command is a little buggy when authenticating in version 1.13.0.
If `export_authors` fails, I highly recommend creating the `authors_export.txt` file manually.
This can be done by running the incantation:
```shell
svn log {{SVN_SERVER_URL}} --quiet | grep "^r" | awk '{print $3}' | sort | uniq > /tmp/svn-to-git/authors_export.txt
```
This may take a while, depending on the size of your SVN repo, but ultimately it will create a file in the /tmp/svn-to-git
directory called `authors_export.txt`. This file will be used automatically by the profiles.