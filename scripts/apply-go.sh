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
    g++ \
    gcc \
    libc6-dev \
    make \
    pkg-config \
    # end of list

try_nonroot_first mkdir -p "$TEMP_DIR" || chown_dir_to_user "$TEMP_DIR"

# golang version
: "${GOLANG_VER:=1.18.3}"

wget https://dl.google.com/go/go$GOLANG_VER.linux-amd64.tar.gz -O "$TEMP_DIR/go.tar.gz"
tar -xzf "$TEMP_DIR/go.tar.gz" -C /usr/local

rm $TEMP_DIR/go.tar.gz