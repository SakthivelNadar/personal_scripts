#!/bin/bash

# Defconfig
if [[ -z ${KERNEL_DEFCONFIG} ]]; then
    echo -n "Enter your kernel defconfig name: "
    read -r NAME
    CONFIG=${KERNEL_DEFCONFIG}
fi

echo "Cloning dependencies"
git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 gcc64 --depth=69
git clone https://github.com/mvaisakh/gcc-arm gcc32 --depth=69

# Compile Plox Sar
echo "Building kernel"
make O=out ARCH=arm64 ${KERNEL_DEFCONFIG}
make 
    O=out \
    ARCH=arm64 \
    CROSS_COMPILE=gcc64/bin/aarch64-elf- \
    CROSS_COMPILE_ARM32=gcc32/bin/arm-eabi- \
    -j$(nproc --all)

