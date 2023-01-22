# SVN to GIT Migration Script
## Background
[Atlassian's SVN-to-GIT migration guide](https://www.atlassian.com/git/tutorials/migrating-overview) is a very good guide
on how to migrate your SVN repository to Git. However, it's not been kept up to date and there are (in some cases)
some very serious issues with it.

This is an attempt at easing / alleviating some headaches while traveling down the road, less traveled.

## Usage
### Prerequisites
* Run under a Linux environment (both the program and the installer will hard quit, if run under anything else)
* Install command-line tools for git (at least v2.25.1) and subversion (at least v1.13.0)
* Install "git-svn bridge" git-svn (at least v2.25.1, it's most likely not installed with the git cli)
* Install cli tools for development
  * On Debian/Ubuntu: `sudo apt install -y make gcc shc`

### Installation
Package the binary and install script by running `make` in the root directory of the project, then running `./target/install.sh`.

### Run
On your first run, you'll be asked to enter SVN login credentials. These will be stored in a file in the `/opt` directory.<br>
On each run, this file will be read and the credentials will be used to authenticate with the SVN server.<br>
Print usage by running:
```shell
svn-to-git help
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