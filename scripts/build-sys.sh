#!/bin/bash
set -e

ROOT=$(dirname "$(realpath "$0")")/..
SRC=$ROOT/src
ROOTFS=$ROOT/rootfs
BUILD=$ROOT/build
KERNEL_SRC=$SRC/kernel        
KERNEL_BUILD=$BUILD/linux     
OUT=$BUILD/out

mkdir -p $OUT
mkdir -p $ROOTFS/usr/bin      

echo "[1/5] Building userland binaries..."
musl-gcc -static -O2 -s -o $ROOTFS/init $SRC/init/init.c
musl-gcc -static -O2 -s -o $ROOTFS/usr/bin/svc-echo $SRC/init/svc-echo.c
chmod +x $ROOTFS/init $ROOTFS/usr/bin/svc-echo
echo "    ✓ init and svc-echo built."

echo "[2/5] Building kernel..."
mkdir -p $KERNEL_BUILD
cd $KERNEL_SRC

# Out-of-tree build
if [ ! -f $KERNEL_BUILD/.config ]; then
    echo "    Configuring default kernel..."
    make O=$KERNEL_BUILD defconfig
fi

make O=$KERNEL_BUILD -j$(nproc)
cp $KERNEL_BUILD/arch/x86/boot/bzImage $OUT/bzImage
cd $ROOT
echo "    ✓ Kernel built."

echo "[3/5] Building root filesystem..."
cd $ROOTFS
find . | cpio -H newc -o | gzip > $OUT/rootfs.cpio.gz
cd $ROOT
echo "    ✓ Rootfs ready."

echo "[4/5] Creating disk image..."
cat > $OUT/run_qemu.sh <<'EOF'
#!/bin/bash
qemu-system-x86_64 \
  -kernel build/out/bzImage \
  -initrd build/out/rootfs.cpio.gz \
  -append "console=ttyS0" \
  -nographic
EOF
chmod +x $OUT/run_qemu.sh
echo "    ✓ QEMU run script generated."

echo "[5/5] Done!"
echo "To boot your OS:"
echo "    ./build/out/run_qemu.sh"
