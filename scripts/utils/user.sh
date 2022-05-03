#!/bin/bash
#
# Copyright 2020, Data61/CSIRO
#
# SPDX-License-Identifier: BSD-2-Clause
#

set -exuo pipefail

####################################################################
# Setup user and groups for inside the container

# It seems that clashes with group names or GIDs is more common
# than one might think. Here we attempt to make a matching group
# inside the container, but if it fails, we abandon the attempt.

# Try to create the group to match the GID. If a group already exists
# with that name, but a different GID, no change will be made.
# We therefore run groupmod to ensure the GID does match what was
# requested.
# However, either of these steps could fail - but if they do,
# that's OK.
groupadd -fg "${GID}" "${GROUP}" || true
groupmod -g "${GID}" "${GROUP}" || true

# Split the group info into an array
IFS=":" read -r -a group_info <<< "$(getent group "$GROUP")"
fgroup="${group_info[0]}"
fgid="${group_info[2]}"

GROUP_OK=false
if [ "$fgroup" == "$GROUP" ] && [ "$fgid" == "$GID" ] ; then
    # This means the group creation has gone OK, so make a user
    # with the corresponding group
    GROUP_OK=true
fi

if [ "$GROUP_OK" = true ]; then
    useradd -u "${UID}" -g "${GID}" "${UNAME}"
else
    # If creating the group didn't work well, that's OK, just
    # make the user without the same group as the host. Not as
    # nice, but still works fine.
    useradd -u "${UID}" "${UNAME}"
fi

# Remove the user's password
passwd -d "${UNAME}"


####################################################################
# Setup sudo for inside the container

# Whenever someone uses sudo, be annoying and remind them that
# it won't be permanent
cat << EOF >> /etc/sudoers
Defaults        lecture_file = /etc/sudoers.lecture
Defaults        lecture = always
EOF

cat << EOF > /etc/sudoers.lecture
##################### Warning! #####################################
This is an ephemeral docker container! You can do things to it using
sudo, but when you exit, changes made outside of the /host directory
will be lost.
If you want your changes to be permanent, add them to the
    extras.dockerfile
in the dev-env dockerfiles repo.
####################################################################

EOF


####################################################################
# Setup home dir

# NOTE: the user's home directory is stored in a docker volume.
#       (normally called $UNAME_home on the host)
#       That implies that these instructions will only run if said
#       docker volume does not exist. Therefore, if the below
#       changes, users will only see the effect if they run:
#          docker volume rm $USER_home

mkdir "/home/${UNAME}"

# Put in some branding
# shellcheck disable=SC2129
cat << EOF >> "/home/${UNAME}/.bashrc"
echo '   ___  __  ____                '
echo '  / _ \/  |/  ( )___            '
echo ' / // / /|_/ /|/(_-<            '
echo '/____/_/  /_/  /___/            '
echo ' ___/ /__ _  _____ ___ _  __    '
echo '/ _  / -_) |/ / -_) _ \ |/ /    '
echo '\_,_/\__/|___/\__/_//_/___/     '
echo 'Hello, welcome to the dev-env docker build environment of duskmoon'
EOF

# This is a small hack. When the dockerfiles are building, many of
# the env things are set into the .bashrc of root (since they're
# building as the root user). Here we just copy all those declarations
# and put them in this user's .bashrc.
# This can be an issue with regard to the NOTE above, about docker
# volumes.
{ grep "export" /root/.bashrc >> /home/${UNAME}/.bashrc || true ; }

# Note that this block does not do parameter expansion, so will be
# copied verbatim into the user's .bashrc.
# We use this to ensure they start in the /host dir (aka, their
# own file path)
cat << 'EOF' >> "/home/${UNAME}/.bashrc"
cd /host
EOF

# Set an appropriate chown setting, based on if the group setup
# went OK
chown_setting="${UNAME}"
if [ "$GROUP_OK" = true ]; then
    chown_setting="${UNAME}:${GROUP}"
fi

##### Customize #####

# Add scripts here to customize the environment

# # An example of customizing cargo source
# touch "${CARGO_HOME}/config.toml"
# cat << 'EOF' >> "${CARGO_HOME}/config.toml"
# [source.crates-io]
# replace-with = 'rsproxy'

# [source.rsproxy]
# registry = "https://rsproxy.cn/crates.io-index"

# [registries.rsproxy]
# index = "https://rsproxy.cn/crates.io-index"

# [net]
# git-fetch-with-cli = true
# EOF

##### End Customize #####

# Make sure the user owns their home dir
chown -R "$chown_setting" "/home/${UNAME}"
chmod -R ug+rw "/home/${UNAME}"
