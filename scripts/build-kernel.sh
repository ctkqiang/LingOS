#!/bin/bash
set -euo pipefail

WORK=/work
KDIR=${WORK}/src/kernel
OUT=${WORK}/build

mkdir -p $OUT
cd $KDIR

# ConFIG default x86_64 config and strip modules we don't need.......
make defconfig

# build bzImage only what else do you think?
make -j$(nproc) bzImage

cp arch/x86/boot/bzImage $OUT/bzImage

echo "Kernel built: $OUT/bzImage"
