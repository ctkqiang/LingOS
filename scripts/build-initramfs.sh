#!/bin/bash
set -euo pipefail
WORK=/work
ROOTFS=${WORK}/rootfs
BUILD=${WORK}/build

cp /work/src/init/init $ROOTFS/init
chmod +x $ROOTFS/init

if [ ! -e $ROOTFS/bin/sh ]; then
  ln -s /bin/busybox $ROOTFS/bin/sh
fi

#Devices nodes if I understand COrrectly, and root required , right? rigght?
mkdir -p $ROOTFS/dev
mknod -m 622 $ROOTFS/dev/console c 5 1 || true
mknod -m 666 $ROOTFS/dev/null c 1 3 || true

cd $ROOTFS

find . | cpio -H newc -o > $BUILD/initramfs.cpio
gzip -f $BUILD/initramfs.cpio
mv $BUILD/initramfs.cpio.gz $BUILD/initramfs.cpio.gz
echo "initramfs created: $BUILD/initramfs.cpio.gz"
