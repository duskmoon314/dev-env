ARG BASE_IMG=duskmoon/dev-env:base-22
FROM ${BASE_IMG}
LABEL MAINTAINER="duskmoon <kp.campbell.he@duskmoon314.com>"

ARG SCM
ARG DESKTOP_MACHINE=no
ARG MAKE_CACHES=yes
ARG GOLANG_VER=1.18.3

ARG SCRIPT=apply-go.sh

COPY scripts /tmp/

RUN /bin/bash "tmp/${SCRIPT}" \
    && apt clean autoclean \
    && apt autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV PATH "${PATH}:/usr/local/go/bin"