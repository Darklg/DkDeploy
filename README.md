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
HOST="myhost.com"
# FTP USERNAME
LOGIN="username"
# FTP PASSWORD
PASSWORD="password"
# CUSTOM DIR TO DEPLOY
BASEDIR='prod/'
# LOCAL ROOT PROJECT DIR
LOCALDIR="/mywebsites/project/htdocs/${BASEDIR}"
# DISTANT ROOT PROJECT DIR
REMOTEDIR="/var/www/project/htdocs/${BASEDIR}"
```

### Custom files exclusions

Create a file in the DkDeploy dir named exclude-custom.txt.
Set one filename/dirname per line and prefix lines with *.

```
*myfile.txt
*myconfig.txt
```
