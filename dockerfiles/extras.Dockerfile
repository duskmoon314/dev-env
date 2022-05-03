#
# Copyright 2020, Data61/CSIRO
#
# SPDX-License-Identifier: BSD-2-Clause
#

ARG USER_BASE_IMG=duskmoon/dev-env:base-22
# hadolint ignore=DL3006
FROM $USER_BASE_IMG

# This dockerfile is a shim between the images from Dockerhub and the
# user.dockerfile.
# Add extra dependencies in here!


RUN apt-get update -q \
    && apt-get install -y --no-install-recommends \
    # Add more dependencies here
    sudo \
    # end of list