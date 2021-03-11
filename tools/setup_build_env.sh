#!/bin/bash

# Setup Build Environment 
echo "Setting up Build Environment"
sudo apt-get update
sudo apt-get install -y bc bison build-essential curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev unzip openjdk-8-jdk python ccache libtinfo5
sudo apt-get upgrade -y

# Setup git 
echo "Setting up git "
wget https://storage.googleapis.com/git-repo-downloads/repo
chmod a+x repo
sudo install repo /usr/local/bin/repo

# Setup Git Credentials
GIT_USERNAME="$(git config --get user.name)"
GIT_EMAIL="$(git config --get user.email)"
echo "Configuring git"
if [[ -z ${GIT_USERNAME} ]]; then
    echo -n "Enter your name: "
    read -r NAME
    git config --global user.name "${NAME}"
fi
if [[ -z ${GIT_EMAIL} ]]; then
    echo -n "Enter your email: "
    read -r EMAIL
    git config --global user.email "${EMAIL}"
fi
git config --global credential.helper "cache --timeout=7200"
echo "git identity setup successfully!"


