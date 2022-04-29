#!/bin/bash

set -exuo pipefail

# Source common functions with funky bash, as per: https://stackoverflow.com/a/12694189
DIR="${BASH_SOURCE%/*}"
test -d "$DIR" || DIR=$PWD
# shellcheck source=utils/common.sh
. "$DIR/utils/common.sh"

# tmp space for building
: "${TEMP_DIR:=/tmp}"

as_root apt update -q
as_root apt install -y --no-install-recommends \
    libglib2.0-dev \
    libfdt-dev \
    libpixman-1-dev \
    zlib1g-dev \
    ninja-build \
    # end of list

try_nonroot_first mkdir -p "$TEMP_DIR" || chown_dir_to_user "$TEMP_DIR"

# qemu version
: "${QEMU_VER:=7.0.0}"

# Get qemu
wget https://download.qemu.org/qemu-$QEMU_VER.tar.xz -O "$TEMP_DIR/qemu-$QEMU_VER.tar.xz"
tar xJf "$TEMP_DIR/qemu-$QEMU_VER.tar.xz"
cd qemu-$QEMU_VER
./configure
make -j$(nproc)
as_root make install
cd ..

rm $TEMP_DIR/qemu-$QEMU_VER.tar.xz
rm -rf qemu-$QEMU_VER
