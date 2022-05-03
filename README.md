# duskmoon/dev-env

Migrating my development environment to docker image

[docker hub](https://hub.docker.com/repository/docker/duskmoon/dev-env) / [github packages](https://github.com/duskmoon314/dev-env/pkgs/container/dev-env)

## Usage

```bash
# clone the repository
git clone https://github.com/duskmoon314/dev-env.git

# cd to working directory
cd /path/to/your/working/directory

# run the container
USER_BASE_IMG=<tag_name> HOST_DIR=$(pwd) make -C /path/to/dev-env user
```

You can find all available `<tag_name>`s in the below section or on [docker hub](https://hub.docker.com/repository/docker/duskmoon/dev-env) / [github packages](https://github.com/duskmoon314/dev-env/pkgs/container/dev-env).

### Example

Here is an example of running [rCore-Tutorial-v3](https://github.com/LearningOS/rCore-Tutorial-v3) in `qemu6-rust-22`

```bash
cd rCore-Tutorial-v3
USER_BASE_IMG=qemu6-rust-22 HOST_DIR=$(pwd) make -C ~/dev-env user
# in the container
cd os
make run
```

[![asciicast](https://asciinema.org/a/491777.svg)](https://asciinema.org/a/491777)

### Convenient way to use

1. Edit the `Makefile`

   To be more specific, edit the `USER_BASE_IMG` in `Makefile` to your desired image.

2. add line like the following to your `.bashrc` / `.zshrc`

   ```bash
   alias dev-env="HOST_DIR=$(pwd) make -C /path/to/dev-env user"
   ```

3. run `dev-env` in your working directory

## List of environments

- base

  base image with common packages

  ### packages

  - git
  - ssh
  - ca-certificates
  - build-essential
  - iproute2
  - iputils-ping
  - curl
  - wget
  - neovim

  ### tags

  - base-18: ubuntu 18.04
  - base-20: ubuntu 20.04
  - base-22: ubuntu 22.04

- rust

  add rust based on base image

  ### packages

  - rustup
  - cargo
  - rust stable minimal

  ### tags

  - rust-18: rust-stable ubuntu 18.04
  - rust-20: rust-stable ubuntu 20.04
  - rust-22: rust-stable ubuntu 22.04

- qemu

  add qemu based on base image

  ### packages

  - qemu 5.2.0/6.2.0/7.0.0

  ### tags

  - qemu5-18: qemu5.2.0 ubuntu 18.04
  - qemu5-20: qemu5.2.0 ubuntu 20.04
  - qemu5-22: qemu5.2.0 ubuntu 22.04
  - qemu6-18: qemu6.2.0 ubuntu 18.04
  - qemu6-20: qemu6.2.0 ubuntu 20.04
  - qemu6-22: qemu6.2.0 ubuntu 22.04
  - qemu7-18: qemu7.0.0 ubuntu 18.04
  - qemu7-20: qemu7.0.0 ubuntu 20.04
  - qemu7-22: qemu7.0.0 ubuntu 22.04

- qemu-rust

  add qemu & rust based on base image

  ### tags

  - qemu5-rust-18: qemu5.2.0 rust-stable ubuntu 18.04
  - qemu5-rust-20: qemu5.2.0 rust-stable ubuntu 20.04
  - qemu5-rust-22: qemu5.2.0 rust-stable ubuntu 22.04
  - qemu6-rust-18: qemu6.2.0 rust-stable ubuntu 18.04
  - qemu6-rust-20: qemu6.2.0 rust-stable ubuntu 20.04
  - qemu6-rust-22: qemu6.2.0 rust-stable ubuntu 22.04
  - qemu7-rust-18: qemu7.0.0 rust-stable ubuntu 18.04
  - qemu7-rust-20: qemu7.0.0 rust-stable ubuntu 20.04
  - qemu7-rust-22: qemu7.0.0 rust-stable ubuntu 22.04

```

```
