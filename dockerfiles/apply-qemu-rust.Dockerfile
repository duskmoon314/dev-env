ARG BASE_IMG=duskmoon/dev-env:qemu7-22
FROM ${BASE_IMG}
LABEL MAINTAINER="duskmoon <kp.campbell.he@duskmoon314.com>"

ARG SCM
ARG DESKTOP_MACHINE=no
ARG MAKE_CACHES=yes
ARG CARGO_HOME="/usr/local/cargo"
ARG RUSTUP_HOME="/usr/local/rustup"

ARG SCRIPT=apply-rust.sh

COPY scripts /tmp/

RUN /bin/bash "tmp/${SCRIPT}" \
    && apt clean autoclean \
    && apt autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:${CARGO_HOME}/bin" CARGO_HOME="${CARGO_HOME}" RUSTUP_HOME="${RUSTUP_HOME}"