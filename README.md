# DkDeploy

Deploy a local website via FTP.

## How to install

- Install LFTP
    - http://lftp.tech/ or
    - `brew install homebrew/boneyard/lftp`
- Clone or copy https://github.com/Darklg/DkDeploy.git next to your project (Avoid the htdocs if possible)
- Create the config file.

## How to deploy

- Just call deploy.sh : `. myproject/DkDeploy/deploy.sh`

## How to configure

### Config (required)

Create a file in the DkDeploy dir named config.sh

```bash
#!/bin/bash

# FTP HOST
DKDEPLOY_HOST="myhost.com"
# FTP USERNAME
DKDEPLOY_LOGIN="username"
# FTP PASSWORD
DKDEPLOY_PASSWORD="password"
# CUSTOM DIR TO DEPLOY
DKDEPLOY_BASEDIR='prod/'
# LOCAL ROOT PROJECT DIR
DKDEPLOY_LOCALDIR="/mywebsites/project/htdocs/${BASEDIR}"
# DISTANT ROOT PROJECT DIR
DKDEPLOY_REMOTEDIR="/var/www/project/htdocs/${BASEDIR}"
# CUSTOM EXCLUSION RULES
DKDEPLOY_EXCLUDECUSTOM="--exclude-glob *custom_cache/ --exclude-glob *custom_cache_html/";
```

### Custom files exclusions

If you don't want to use the DKDEPLOY_EXCLUDECUSTOM var,
Create a file in the DkDeploy dir named exclude-custom.txt.
Set one filename/dirname per line and prefix lines with *.

```
*myfile.txt
*myconfig.txt
```

### Custom post deploy actions.

Create a file in the DkDeploy dir named post-deploy.sh
It will be triggered after deploy.
