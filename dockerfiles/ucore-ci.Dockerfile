ARG BASE_IMG=ubuntu:20.04
FROM ${BASE_IMG}
LABEL MAINTAINER="duskmoon <kp.campbell.he@duskmoon314.com>"

ARG SCM
ARG DESKTOP_MACHINE=no
ARG MAKE_CACHES=yes

ARG SCRIPT=ucore-ci.sh

COPY scripts /tmp/

RUN echo ipv4 >> ~/.curlrc \
    && /bin/bash "tmp/${SCRIPT}" \
    && apt clean autoclean \
    && apt autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/local/riscv64-unknown-elf-gcc/bin:/usr/local/riscv64-linux-musl-cross/bin:${PATH}:/usr/local/share"