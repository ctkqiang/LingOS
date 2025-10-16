#!/bin/bash
WORK=/work
KIMG=${WORK}/build/bzImage
INITRD=${WORK}/build/initramfs.cpio.gz

if [ ! -f "$KIMG" ]; then echo "Kernel not found: $KIMG"; exit 1; fi
if [ ! -f "$INITRD" ]; then echo "initramfs not found: $INITRD"; exit 1; fi

# I build this in darwin, so I need this
qemu-system-x86_64 -kernel "$KIMG" -initrd "$INITRD" \
  -append "console=ttyS0 root=/dev/ram rdinit=/init" \
  -nographic -m 512
