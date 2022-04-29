# Inspired by the Makefile of seL4/seL4-CAmkES-L4v-dockerfiles
#
# Also based on its Makefile
#
# License of seL4/seL4-CAmkES-L4v-dockerfiles:
#
# # Copyright 2020, Data61/CSIRO
# #
# # SPDX-License-Identifier: BSD-2-Clause
#

# Docker image tool to use
DOCKER ?= docker
DOCKERHUB ?= duskmoon/dev-env:

BASE_IMG ?= base-22
RUST_IMG ?= rust-22
QEMU_IMG ?= qemu

# Base images
USER_BASE_IMG ?= $(BASE_IMG)

# Interactive images
EXTRAS_IMG := dev-env-extras
USER_IMG := dev-env-$(shell whoami)
HOST_DIR ?= $(shell pwd)

# Volumes
DOCKER_VOLUME_HOME ?= $(shell whoami)-dev-env-home

# Extra vars
DOCKER_BUILD ?= $(DOCKER) build
DOCKER_FLAGS ?= --force-rm=true
ifndef EXEC
	EXEC := bash
	DOCKER_RUN_FLAGS += -it
endif

ETC_LOCALTIME := $(realpath /etc/localtime)

# Extra arguments to pass to `docker run` if it is or is not `podman` - these
# are constructed in a very verbose way to be obvious about why we want to do
# certain things under regular `docker` vs` podman`
# Note that `docker --version` will not say "podman" if symlinked.
CHECK_DOCKER_IS_PODMAN  := $(DOCKER) --help 2>&1 | grep -q podman
IF_DOCKER_IS_PODMAN     := $(CHECK_DOCKER_IS_PODMAN) && echo
IF_DOCKER_IS_NOT_PODMAN := $(CHECK_DOCKER_IS_PODMAN) || echo
# If we're not `podman` then we'll use the `-u` and `-g` options to set the
# user in the container
EXTRA_DOCKER_IS_NOT_PODMAN_RUN_ARGS := $(shell $(IF_DOCKER_IS_NOT_PODMAN) \
    "-u $(shell id -u):$(shell id -g)" \
)
# If we are `podman` then we'll prefer to use `--userns=keep-id` to set up and
# use the appropriate sub{u,g}id mappings rather than end up using UID 0 in the
# container
EXTRA_DOCKER_IS_PODMAN_RUN_ARGS     := $(shell $(IF_DOCKER_IS_PODMAN) \
    "--userns=keep-id" \
)
# And we'll jam them into one variable to reduce noise in `docker run` lines
EXTRA_DOCKER_RUN_ARGS   := $(EXTRA_DOCKER_IS_NOT_PODMAN_RUN_ARGS) \
                           $(EXTRA_DOCKER_IS_PODMAN_RUN_ARGS)

##########
# Making docker easier to use by mapping current user into a container
##########

.PHONY: user
user: user_base

.PHONY: user_base
user_base: build_user_base user_run

.PHONY: user_rust
user_rust: build_user_rust user_run

.PHONY: user_qemu
user_qemu: build_user_qemu user_run

.PHONY: user_run
user_run:
	$(DOCKER) run \
		$(DOCKER_RUN_FLAGS) \
		--hostname devenv-container \
		--rm \
		$(EXTRA_DOCKER_RUN_ARGS) \
		--group-add sudo \
		-v $(HOST_DIR):/host:z \
		-v $(DOCKER_VOLUME_HOME):/home/$(shell whoami):z \
		-v $(ETC_LOCALTIME):/etc/localtime:ro \
		$(USER_IMG) $(EXEC)


.PHONY: run_checks
run_checks:
ifeq ($(shell id -u),0)
	@echo "You are running this as root (either via sudo, or directly)."
	@echo "This system is designed to run under your own user account."
	@echo "You can add yourself to the docker group to make this work:"
	@echo "    sudo su -c usermod -aG docker your_username"
	@exit 1
endif

.PHONY: build_user
build_user: run_checks
	$(DOCKER_BUILD) $(DOCKER_FLAGS) \
		--build-arg=USER_BASE_IMG=$(DOCKERHUB)$(USER_BASE_IMG) \
		-f dockerfiles/extras.Dockerfile \
		-t $(EXTRAS_IMG) \
		.
	$(DOCKER_BUILD) $(DOCKER_FLAGS) \
		--build-arg=EXTRAS_IMG=$(EXTRAS_IMG) \
		--build-arg=UNAME=$(shell whoami) \
		--build-arg=UID=$(shell id -u) \
		--build-arg=GID=$(shell id -g) \
		--build-arg=GROUP=$(shell id -gn) \
		-f dockerfiles/user.Dockerfile \
		-t $(USER_IMG) \
		.
build_user_base: USER_BASE_IMG = $(BASE_IMG)
build_user_base: build_user
build_user_rust: USER_BASE_IMG = $(RUST_IMG)
build_user_rust: build_user
build_user_qemu: USER_BASE_IMG = $(QEMU_IMG)
build_user_qemu: build_user

.PHONY: clean_home_dir
clean_home_dir:
	$(DOCKER) volume rm $(DOCKER_VOLUME_HOME)

.PHONY: clean_data
clean_data: clean_home_dir

.PHONY: clean_images
	-$(DOCKER) rmi $(USER_IMG)
	-$(DOCKER) rmi $(EXTRAS_IMG)

.PHONY: clean
clean: clean_data clean_images