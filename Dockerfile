ARG BASE_IMG=ubuntu:22.04
FROM ${BASE_IMG}
LABEL MAINTAINER="duskmoon <kp.campbell.he@duskmoon314.com>"

# Use duskmoon314/dotfiles to build
COPY dotfiles/ /usr/local/.dotfiles/

ENV DOTFILES_DIR=/usr/local/.dotfiles
ARG DOTFILES_ARGS="set -C base"
ARG DOTFILES_ENV=""

RUN ${DOTFILES_ENV} /bin/bash ${DOTFILES_DIR}/main ${DOTFILES_ARGS}