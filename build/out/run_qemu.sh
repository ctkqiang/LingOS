#!/bin/bash
set -e
echo "[+] Starting QEMU for architecture: arm64"
qemu-system-arm64 \
  -kernel build/out/bzImage \
  -initrd build/out/rootfs.cpio.gz \
  -append "console=ttyAMA0" \
  -nographic
