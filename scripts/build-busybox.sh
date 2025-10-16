#!/bin/bash
set -euo pipefail

WORK=/work
BDIR=${WORK}/src/busybox
ROOTFS=${WORK}/rootfs

cd $BDIR
make defconfig

sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config || true
make -j$(nproc)

rm -rf $ROOTFS
make CONFIG_PREFIX=$ROOTFS install

mkdir -p $ROOTFS/{proc,sys,dev,tmp,etc,root,bin,sbin,usr/bin,usr/sbin}
chmod 755 $ROOTFS/tmp

echo "BusyBox installed to $ROOTFS"
