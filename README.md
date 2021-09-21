# duskmoon/dev-env

Migrating my development environment to docker image

## ubuntu-base

`duskmoon/dev-env:ubuntu-20.04-base` `duskmoon/dev-env:ubuntu-21.04-base`

based on ubuntu 20.04 / 21.04

- zsh
  - oh-my-zsh
  - p10k
- git
- curl
- build-essential

### qemu-dep

`duskmoon/dev-env:ubuntu-20.04-qemu-dep`

based on ubuntu-20.04-base, install dependencies to build qemu

no qemu (bin or source code) in this image

according to https://wiki.qemu.org/Hosts/Linux
