apt install -y qemu-system-arm qemu-system-misc qemu-efi-aarch64

file ./build/out/bzImage

qemu-system-aarch64 \
  -M virt \
  -cpu cortex-a72 \
  -m 1024 \
  -kernel /work/build/linux/arch/arm64/boot/Image.gz \
  -initrd /work/build/out/rootfs.cpio.gz \
  -append "console=ttyAMA0" \
  -nographic
