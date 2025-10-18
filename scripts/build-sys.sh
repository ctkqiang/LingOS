#!/bin/bash
set -e

ROOT=$(dirname "$(realpath "$0")")/..
SRC=$ROOT/src
ROOTFS=$ROOT/rootfs
BUILD=$ROOT/build
KERNEL_SRC=$SRC/kernel
KERNEL_BUILD=$BUILD/linux
OUT=$BUILD/out

mkdir -p "$OUT"
mkdir -p "$ROOTFS/usr/bin"

echo "[1/5] Building userland binaries..."
echo "    Compiling init..."
musl-gcc -static -O2 -s -o "$ROOTFS/init" "$SRC/init/init.c"
echo "    Compiling svc-echo..."
musl-gcc -static -O2 -s -o "$ROOTFS/usr/bin/svc-echo" "$SRC/init/svc-echo.c"
chmod +x "$ROOTFS/init" "$ROOTFS/usr/bin/svc-echo"
echo "    Userland binaries built successfully."

echo
echo "[2/5] Building kernel..."
mkdir -p "$KERNEL_BUILD"
cd "$KERNEL_SRC"

if [ ! -f "$KERNEL_BUILD/.config" ]; then
    echo "    No existing kernel configuration found."
    echo "    Running 'make O=$KERNEL_BUILD defconfig'..."
    make O="$KERNEL_BUILD" defconfig
else
    echo "    Existing kernel configuration detected. Skipping defconfig."
fi

echo "    Starting kernel compilation..."
make O="$KERNEL_BUILD" -j"$(nproc)" V=1

echo "    Kernel build finished. Detecting architecture..."

ARCH_DIR=""
IMAGE_PATH=""

if [ -d "$KERNEL_BUILD/arch/x86/boot" ]; then
    ARCH_DIR="x86"
    IMAGE_PATH="$KERNEL_BUILD/arch/x86/boot/bzImage"
elif [ -d "$KERNEL_BUILD/arch/arm64/boot" ]; then
    ARCH_DIR="arm64"
    if [ -f "$KERNEL_BUILD/arch/arm64/boot/Image.gz" ]; then
        IMAGE_PATH="$KERNEL_BUILD/arch/arm64/boot/Image.gz"
    elif [ -f "$KERNEL_BUILD/arch/arm64/boot/Image" ]; then
        IMAGE_PATH="$KERNEL_BUILD/arch/arm64/boot/Image"
    fi
fi

if [ -z "$ARCH_DIR" ]; then
    echo "Error: Unable to determine architecture. No valid boot directory found in $KERNEL_BUILD/arch/"
    exit 1
fi

if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: Kernel image not found at $IMAGE_PATH"
    exit 1
fi

echo "    Architecture detected: $ARCH_DIR"
echo "    Copying kernel image to $OUT/bzImage"
cp "$IMAGE_PATH" "$OUT/bzImage"

cd "$ROOT"
echo "    Kernel build process complete."

echo
echo "[3/5] Building root filesystem..."
cd "$ROOTFS"
echo "    Generating compressed CPIO archive..."
find . | cpio -H newc -o | gzip > "$OUT/rootfs.cpio.gz"
cd "$ROOT"
echo "    Root filesystem created successfully."

echo
echo "[4/5] Generating QEMU run script..."
cat > "$OUT/run_qemu.sh" <<EOF
#!/bin/bash
set -e
echo "[+] Starting QEMU for architecture: $ARCH_DIR"
qemu-system-$ARCH_DIR \\
  -kernel build/out/bzImage \\
  -initrd build/out/rootfs.cpio.gz \\
  -append "console=ttyAMA0" \\
  -nographic
EOF

chmod +x "$OUT/run_qemu.sh"
echo "    QEMU run script generated at: $OUT/run_qemu.sh"

echo
echo "[5/5] Build completed successfully."
echo "------------------------------------------------------------"
echo "Output files:"
echo "  Kernel Image: $OUT/bzImage"
echo "  Rootfs:       $OUT/rootfs.cpio.gz"
echo "  Run Script:   $OUT/run_qemu.sh"
echo "------------------------------------------------------------"
echo "To boot your custom OS, execute:"
echo "  ./build/out/run_qemu.sh"
echo "------------------------------------------------------------"
