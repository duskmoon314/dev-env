#!/bin/bash

set -exuo pipefail

# Source common functions with funky bash, as per: https://stackoverflow.com/a/12694189
DIR="${BASH_SOURCE%/*}"
test -d "$DIR" || DIR=$PWD
# shellcheck source=utils/common.sh
. "$DIR/utils/common.sh"

# General usage scripts location
: "${SCRIPTS_DIR:=$HOME/bin}"

# By default, assume we are on a desktop (usually less destructive)
: "${DESKTOP_MACHINE:=yes}"

# Docker may set this variable - fill if not set
: "${SCM:=https://github.com}"

as_root apt update -q
as_root apt install -y --no-install-recommends \
    git \
    ssh \
    ca-certificates \
    build-essential \
    iproute2 \
    iputils-ping \
    curl \
    wget \
    neovim \
    # end of list

# Add some symlinks so some programs can find things
if [ "$DESKTOP_MACHINE" = "no" ] ; then
    as_root ln -s /usr/bin/hg /usr/local/bin/hg
fi

try_nonroot_first mkdir -p "$SCRIPTS_DIR" || chown_dir_to_user "$SCRIPTS_DIR"