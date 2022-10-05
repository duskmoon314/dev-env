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
: "${CARGO_HOME:=/usr/local/cargo}"
: "${RUSTUP_HOME:=/usr/local/rustup}"

as_root apt update -q
as_root apt install -y --no-install-recommends \
    curl \
    wget \
    ssh \
    ca-certificates \
    build-essential \
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

# Get rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >"$TEMP_DIR/rustup.sh"

sh "$TEMP_DIR/rustup.sh" -y --profile minimal --no-modify-path --default-toolchain nightly
rm "$TEMP_DIR/rustup.sh"

# Update the current shell
# shellcheck disable=SC1090
source "$CARGO_HOME"/env

rustup --version
cargo --version
rustc --version

# Setup targets and components
rustup target add riscv64gc-unknown-none-elf
cargo install cargo-binutils --vers ~0.2
rustup component add rust-src llvm-tools-preview

# Make sure that all the files are accessible to other users:
try_nonroot_first chmod -R a+w "$CARGO_HOME" "$RUSTUP_HOME"

# Set crates.io mirror
touch "${CARGO_HOME}/config.toml"
cat <<'EOF' >>"${CARGO_HOME}/config.toml"
[source.crates-io]
replace-with = 'rsproxy'

[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"

[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"

[net]
git-fetch-with-cli = true
EOF
