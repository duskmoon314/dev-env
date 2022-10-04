#!/bin/bash

set -exuo pipefail

# Source common functions with funky bash, as per: https://stackoverflow.com/a/12694189
DIR="${BASH_SOURCE%/*}"
test -d "$DIR" || DIR=$PWD
# shellcheck source=utils/common.sh
. "$DIR/utils/common.sh"

# General usage scripts location
: "${SCRIPTS_DIR:=$HOME/bin}"

# tmp space for building
: "${TEMP_DIR:=/tmp}"

as_root apt update -q
as_root apt install -y --no-install-recommends \
    curl \
    wget \
    ssh \
    ca-certificates \
    build-essential \
    cmake \
    autoconf \
    automake \
    autotools-dev \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    gawk \
    bison \
    flex \
    texinfo \
    gperf \
    libtool \
    patchutils \
    bc \
    xz-utils \
    libexpat-dev \
    pkg-config \
    libglib2.0-dev \
    libfdt-dev \
    libpixman-1-dev \
    zlib1g-dev \
    ninja-build \
    git \
    tmux \
    python3
# end of list

try_nonroot_first mkdir -p "$TEMP_DIR" || chown_dir_to_user "$TEMP_DIR"

# Get riscv64-unknown-elf-gcc
wget -c https://static.dev.sifive.com/dev-tools/freedom-tools/v2020.08/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14.tar.gz -O "$TEMP_DIR/riscv64-unknown-elf-gcc.tar.gz"
try_nonroot_first mkdir -p riscv64-unknown-elf-gcc || chown_dir_to_user riscv64-unknown-elf-gcc
tar -xzf "$TEMP_DIR/riscv64-unknown-elf-gcc.tar.gz" -C riscv64-unknown-elf-gcc --strip-components=1
as_root mv riscv64-unknown-elf-gcc /usr/local/riscv64-unknown-elf-gcc
rm "$TEMP_DIR/riscv64-unknown-elf-gcc.tar.gz"

# Get musl-gcc
wget -c https://cloud.tsinghua.edu.cn/f/cc4af959a6fc469e8564/?dl=1 -O "$TEMP_DIR/riscv64-linux-musl-cross.tgz"
tar -xzf "$TEMP_DIR/riscv64-linux-musl-cross.tgz"
as_root mv riscv64-linux-musl-cross /usr/local/riscv64-linux-musl-cross
rm "$TEMP_DIR/riscv64-linux-musl-cross.tgz"

# qemu version
: "${QEMU_VER:=7.0.0}"

# Get qemu
wget https://download.qemu.org/qemu-$QEMU_VER.tar.xz -O "$TEMP_DIR/qemu-$QEMU_VER.tar.xz"
tar -xJf "$TEMP_DIR/qemu-$QEMU_VER.tar.xz"
cd qemu-$QEMU_VER
./configure --target-list=riscv64-softmmu,riscv64-linux-user
make -j$(nproc)
as_root make install
cd ..

rm $TEMP_DIR/qemu-$QEMU_VER.tar.xz
rm -rf qemu-$QEMU_VER
