#!/bin/bash

###################################
## DK Deploy v 0.1.0
## License MIT
## https://github.com/Darklg/DkDeploy

###################################
## LOAD SCRIPT DIR
###################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

###################################
## LOAD HELPERS
###################################

. "${SCRIPT_DIR}/inc/helper.sh";

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

. "${SCRIPT_DIR}/config.sh";

###################################
## CHECK IF PUSH IS POSSIBLE
###################################

cd "${LOCALDIR}";

# On master branch
# http://stackoverflow.com/a/1593487
branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
branch_name="(unnamed branch)"
branch_name=${branch_name##refs/heads/}
if [ $branch_name != 'master' ]; then
    echo '- /!\ You must be on the master branch to deploy.';
    return;
fi;

# Everything is commited
if [[ -n $(git status -s) ]]; then
    echo '- /!\ You have uncommited changes, please move them to the develop branch.';
    return;
fi;

cd "${SCRIPT_DIR}";

###################################
## DRY RUN ?
###################################

ENABLEDRYRUN='--dry-run';
read -p "Disable Dry run ? [y/N] : " disable_dry_run
if [[ $disable_dry_run == 'y' ]]; then
    ENABLEDRYRUN='';
    echo '- Dry run is *disabled*. Changes *will* be applied.';
else
    echo '- Dry run is *enabled*. Changes *will not* be applied.';
fi;

###################################
## LOAD EXCLUDES
###################################

EXCLUDELIST=$(sed 's/^/--exclude-glob /' exclude-lists/base.txt | tr '\n' ' ');
EXCLUDEWP=$(sed 's/^/--exclude-glob /' exclude-lists/wordpress.txt | tr '\n' ' ');
EXCLUDECUSTOM='';
if [[ -f 'exclude-custom.txt' ]];then
    echo '- Loading custom exclusion rules.';
    EXCLUDECUSTOM=$(sed 's/^/--exclude-glob /' exclude-custom.txt | tr '\n' ' ');
fi;

###################################
## DEPLOY
###################################

# Allow user to view messages or do a last second stop.
sleep 2;

lftp -c "set ftp:list-options -a;
open ftp://$LOGIN:$PASSWORD@$HOST;
lcd $LOCALDIR;
cd $REMOTEDIR;
mirror \
--reverse \
--only-newer \
--verbose \
$ENABLEDRYRUN \
$EXCLUDELIST \
$EXCLUDEWP \
$EXCLUDECUSTOM \
";

###################################
## CONFIRM
###################################

echo '- Deploy is done !';
cd "${LOCALDIR}";
