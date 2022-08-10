#!/bin/bash

set -exuo pipefail

# Source common functions with funky bash, as per: https://stackoverflow.com/a/12694189
DIR="${BASH_SOURCE%/*}"
test -d "$DIR" || DIR=$PWD
# shellcheck source=utils/common.sh
. "$DIR/utils/common.sh"

as_root apt update -q
as_root apt install -y --no-install-recommends \
    subversion \
    libncurses5-dev \
    zlib1g-dev \
    gawk \
    flex \
    quilt \
    libssl-dev \
    xsltproc \
    libxml-parser-perl \
    mercurial \
    bzr \
    ecj \
    cvs \
    unzip \
    lib32z1 \
    lib32z1-dev \
    lib32stdc++6 \
    libstdc++6 \
    python3 \
    python-is-python3 \
    xxd \
    # end of list