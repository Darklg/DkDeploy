#!/bin/bash

###################################
## DK Deploy v 0.2.0
## License MIT
## https://github.com/Darklg/DkDeploy

###################################
## LOAD SCRIPT DIR
###################################

DKDEPLOY_SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

###################################
## LOAD DEPENDENCIES
###################################

# Helper functions
. "${DKDEPLOY_SCRIPTDIR}/inc/helper.sh";

# Reset user vars
. "${DKDEPLOY_SCRIPTDIR}/inc/reset.sh";

###################################
## CHECK REQUIREMENTS
###################################

if dkdeploy_command_exists lftp ; then
    echo '- LFTP is installed.'
else
    echo '- /!\ LFTP is not installed.';
    return;
fi

###################################
## LOAD INFOS
###################################

. "${DKDEPLOY_SCRIPTDIR}/config.sh";

# Check infos
if [ -z ${DKDEPLOY_HOST+x} ] || [ -z ${DKDEPLOY_LOGIN+x} ] || [ -z ${DKDEPLOY_PASSWORD+x} ] || [ -z ${DKDEPLOY_LOCALDIR+x} ] || [ -z ${DKDEPLOY_REMOTEDIR+x} ];then
    echo '- /!\ The config file is invalid. Please define all the necessary vars : DKDEPLOY_HOST, DKDEPLOY_LOGIN, DKDEPLOY_PASSWORD, DKDEPLOY_LOCALDIR, DKDEPLOY_REMOTEDIR.';
    return;
fi;

###################################
## CHECK IF PUSH IS POSSIBLE
###################################

cd "${DKDEPLOY_LOCALDIR}";

# On master branch
# http://stackoverflow.com/a/1593487
DKDEPLOY_CURRENT_BRANCH="$(git symbolic-ref HEAD 2>/dev/null)" ||
DKDEPLOY_CURRENT_BRANCH="(unnamed branch)"
DKDEPLOY_CURRENT_BRANCH=${DKDEPLOY_CURRENT_BRANCH##refs/heads/}
if [ $DKDEPLOY_CURRENT_BRANCH != 'master' ]; then
    echo '- /!\ You must be on the master branch to deploy.';
    return;
fi;

# Everything is commited
if [[ -n $(git status -s) ]]; then
    echo '- /!\ You have uncommited changes, please move them to the develop branch.';
    return;
fi;

cd "${DKDEPLOY_SCRIPTDIR}";

###################################
## DRY RUN ?
###################################

DKDEPLOY_ENABLEDRYRUN='--dry-run';
read -p "Disable Dry run ? [y/N] : " tmp__disable_dry_run
if [[ $tmp__disable_dry_run == 'y' ]]; then
    DKDEPLOY_ENABLEDRYRUN='';
    echo '- Dry run is *disabled*. Changes *will* be applied.';
else
    echo '- Dry run is *enabled*. Changes *will not* be applied.';
fi;

###################################
## LOAD EXCLUDES
###################################

DKDEPLOY_EXCLUDELIST=$(sed 's/^/--exclude-glob /' exclude-lists/base.txt | tr '\n' ' ');
DKDEPLOY_EXCLUDEWP=$(sed 's/^/--exclude-glob /' exclude-lists/wordpress.txt | tr '\n' ' ');
if [ -z ${DKDEPLOY_EXCLUDECUSTOM+x} ]; then
    DKDEPLOY_EXCLUDECUSTOM='';
fi
if [[ -f 'exclude-custom.txt' ]];then
    echo '- Loading custom exclusion rules.';
    DKDEPLOY_EXCLUDECUSTOM=$(sed 's/^/--exclude-glob /' exclude-custom.txt | tr '\n' ' ');
fi;

###################################
## DEPLOY
###################################

# Allow user to view messages or do a last second stop.
sleep 2;

lftp -c "set ftp:list-options -a;
open ftp://$DKDEPLOY_LOGIN:$DKDEPLOY_PASSWORD@$DKDEPLOY_HOST;
lcd $DKDEPLOY_LOCALDIR;
cd $DKDEPLOY_REMOTEDIR;
mirror \
--reverse \
--only-newer \
--verbose \
$DKDEPLOY_ENABLEDRYRUN \
$DKDEPLOY_EXCLUDELIST \
$DKDEPLOY_EXCLUDEWP \
$DKDEPLOY_EXCLUDECUSTOM \
";

###################################
## CONFIRM
###################################

if [[ -f 'post-deploy.sh' ]];then
    echo '- Loading custom post deploy actions.';
    . "post-deploy.sh";
fi;

echo '- Deploy is done !';
cd "${DKDEPLOY_LOCALDIR}";

# Reset user vars
. "${DKDEPLOY_SCRIPTDIR}/inc/reset.sh";
