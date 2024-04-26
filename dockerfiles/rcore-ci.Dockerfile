ARG BASE_IMG=ubuntu:24.04
FROM ${BASE_IMG}
LABEL MAINTAINER="duskmoon <kp.campbell.he@duskmoon314.com>"

ARG SCM
ARG DESKTOP_MACHINE=no
ARG MAKE_CACHES=yes
ARG QEMU_VER=7.0.0
ARG CARGO_HOME="/usr/local/cargo"
ARG RUSTUP_HOME="/usr/local/rustup"

ARG SCRIPT=rcore-ci.sh

COPY scripts /tmp/

RUN echo ipv4 >> ~/.curlrc \
    && /bin/bash "tmp/${SCRIPT}" \
    && apt clean autoclean \
    && apt autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:${CARGO_HOME}/bin:/usr/local/share" \
    CARGO_HOME="${CARGO_HOME}" \
    RUSTUP_HOME="${RUSTUP_HOME}" \
    RUSTUP_DIST_SERVER="https://rsproxy.cn" \
    RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup" \
    CARGO_HTTP_MULTIPLEXING="false"