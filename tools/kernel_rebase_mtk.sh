#!/bin/bash

# SPDX-License-Identifier: GPL-3.0-or-later
#
# Copyright (C) 2019 Shivam Kumar Jha <jha.shivam3@gmail.com>
# Copyright (C) 2021 Sakthivel Nadar <s2234nadar@gmail.com>
#
# Helper functions

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

# Store project path
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null && pwd )"

# Arguements check
if [ -z ${1} ] || [ -z ${2} ]; then
    echo -e "Usage: bash kernel_rebase_mtk.sh <kernel zip link/file> <repo name> <OPTIONAL: tag suffix>"
fi

# Download compressed kernel source
if [[ "$1" == *"http"* ]]; then
    URL=${1}
    dlrom
else
    URL=$( realpath "$1" )
    echo "Copying file"
    cp -a ${1} ${PROJECT_DIR}/input/
fi
FILE=${URL##*/}
EXTENSION=${URL##*.}
UNZIP_DIR=${FILE/.$EXTENSION/}
[[ -d ${PROJECT_DIR}/kernels/${UNZIP_DIR} ]] && rm -rf ${PROJECT_DIR}/kernels/${UNZIP_DIR}

# Extract file
echo "Extracting file"
mkdir -p ${PROJECT_DIR}/kernels/${UNZIP_DIR}
7z x ${PROJECT_DIR}/input/${FILE} -y -o${PROJECT_DIR}/kernels/${UNZIP_DIR} > /dev/null 2>&1
KERNEL_DIR="$(dirname "$(find ${PROJECT_DIR}/kernels/${UNZIP_DIR} -type f -name "AndroidKernel.mk" | head -1)")"
AUDIO_KERNEL_DIR="$(dirname "$(find ${PROJECT_DIR}/kernels/${UNZIP_DIR} -type d -name "audio-kernel" | head -1)")"
[[ ! -e ${KERNEL_DIR}/Makefile ]] && KERNEL_DIR="$(dirname "$(find ${PROJECT_DIR}/kernels/${UNZIP_DIR} -type f -name "build.config.goldfish.arm64" | head -1)")"
NEST="$( find ${PROJECT_DIR}/kernels/${UNZIP_DIR} -type f -size +50M -printf '%P\n' | head -1)"
if [ ! -z ${NEST} ] && [[ ! -e ${KERNEL_DIR}/Makefile ]]; then
    bash ${PROJECT_DIR}/tools/rebase_kernel.sh ${PROJECT_DIR}/kernels/${UNZIP_DIR}/${NEST} ${2} ${3}
    rm -rf ${PROJECT_DIR}/input/${NEST}
    rm -rf ${PROJECT_DIR}/kernels/${UNZIP_DIR}
    exit
fi
cd ${KERNEL_DIR}
[[ -d ${KERNEL_DIR}/.git/ ]] && rm -rf ${KERNEL_DIR}/.git/

# Find kernel version
KERNEL_VERSION="$( cat Makefile | grep VERSION | head -n 1 | sed "s|.*=||1" | sed "s| ||g" )"
KERNEL_PATCHLEVEL="$( cat Makefile | grep PATCHLEVEL | head -n 1 | sed "s|.*=||1" | sed "s| ||g" )"
[[ -z "$KERNEL_VERSION" ]] && echo -e "Error!" && exit 1
[[ -z "$KERNEL_PATCHLEVEL" ]] && echo -e "Error!" && exit 1
echo "${KERNEL_VERSION}.${KERNEL_PATCHLEVEL}"

# Create release branch
echo "Creating release branch"
cd ${PROJECT_DIR}/kernels/mtk-${KERNEL_VERSION}.${KERNEL_PATCHLEVEL}
git checkout -b release -q
rm -rf *
cp -a ${KERNEL_DIR}/* ${PROJECT_DIR}/kernels/mtk-${KERNEL_VERSION}.${KERNEL_PATCHLEVEL}
git add --all > /dev/null 2>&1
git -c "user.name=${GIT_USERNAME}" -c "user.email=${GIT_EMAIL}" commit -sm "OEM Release" > /dev/null 2>&1
rm -rf ${PROJECT_DIR}/kernels/${UNZIP_DIR}

# Apply OEM modifications
echo "Applying OEM modifications"
git diff "release-" release | git apply --reject > /dev/null 2>&1
DIFFPATHS=(
    "Documentation/"
    "arch/arm/boot/dts/"
    "arch/arm64/boot/dts/"
    "arch/arm/configs/"
    "arch/arm64/configs/"
    "arch/"
    "block/"
    "crypto/"
    "drivers/android/"
    "drivers/base/"
    "drivers/block/"
    "drivers/media/"
    "drivers/char/"
    "drivers/clk/"
    "drivers/cpufreq/"
    "drivers/cpuidle/"
    "drivers/gpu/"
    "drivers/input/touchscreen/"
    "drivers/input/"
    "drivers/leds/"
    "drivers/misc/"
    "drivers/mmc/"
    "drivers/nfc/"
    "drivers/power/"
    "drivers/scsi/"
    "drivers/soc/"
    "drivers/thermal/"
    "drivers/usb/"
    "drivers/video/"
    "drivers/"
    "firmware/"
    "fs/"
    "include/"
    "kernel/"
    "mm/"
    "net/"
    "security/"
    "sound/"
    "tools/"
)
for ELEMENT in ${DIFFPATHS[@]}; do
    [[ -d $ELEMENT ]] && git add $ELEMENT > /dev/null 2>&1
    git -c "user.name=${GIT_USERNAME}" -c "user.email=${GIT_EMAIL}" commit -sm "Add $ELEMENT modifications" > /dev/null 2>&1
done
# Remaining OEM modifications
git add --all > /dev/null 2>&1
git -c "user.name=${GIT_USERNAME}" -c "user.email=${GIT_EMAIL}" commit -sm "Add remaining OEM modifications" > /dev/null 2>&1
