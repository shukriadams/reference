#!/bin/sh
# What ?
# Very simple script to solve classic chicken-egg bootstrapping of a git repo used in a CI build job, called from the build job.
#
# Why ?
# Keep build logic in git. Easily ensure latest build logic somewhere in build space with just two lines of code.
# 
# Use :
# wget https://raw.githubusercontent.com/shukriadams/reference/master/ensure-git-checkout.sh 
# sh ./ensure-git-checkout.sh -u https://github.com/some/depot.git -p /some/path
#
set -e

REPO_URL=""
CHECKOUT_PATH=""

while [ -n "$1" ]; do 
    case "$1" in
    -u|--url)
        REPO_URL="$2" shift;;
    -p|--path)
        CHECKOUT_PATH="$2" shift;;            
    esac 
    shift
done

if [ -z $REPO_URL ]; then
   echo "ERROR : --url not set."
   exit 1
fi

if [ -z $CHECKOUT_PATH ]; then
   echo "ERROR : --path not set."
   exit 1
fi

if [ -d "${CHECKOUT_PATH}" ]; then
    if [ ! -d "${CHECKOUT_PATH}/.git" ]; then
        echo "checkout at ${CHECKOUT_PATH} is missing .git directory and is likely corrupt. Manual intervention required"
        exit 1
    fi        
fi

if [ -d "${CHECKOUT_PATH}" ] 
then
    echo "Get latest version of ${CHECKOUT_PATH}..." 
    cd $CHECKOUT_PATH
    git reset --hard
    git clean -fx
    git pull
    git fetch --all --tags -f
else
    echo "${CHECKOUT_PATH} not found, cloning new ..."
    git clone $REPO_URL $CHECKOUT_PATH
fi
