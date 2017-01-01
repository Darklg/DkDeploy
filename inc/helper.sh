#!/bin/bash

# Check if a command exists
# http://stackoverflow.com/a/3931779
dkdeploy_command_exists () {
    type "$1" &> /dev/null ;
}
