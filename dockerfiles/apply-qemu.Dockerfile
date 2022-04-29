ARG BASE_IMG=duskmoon/dev-env:base-22
FROM ${BASE_IMG}
LABEL MAINTAINER="duskmoon <kp.campbell.he@duskmoon314.com>"

ARG SCM
ARG DESKTOP_MACHINE=no
ARG MAKE_CACHES=yes
ARG QEMU_VER=7.0.0

ARG SCRIPT=apply-qemu.sh

COPY scripts /tmp/

RUN /bin/bash "tmp/${SCRIPT}" \
    && apt clean autoclean \
    && apt autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV PATH "${PATH}:/usr/local/share"