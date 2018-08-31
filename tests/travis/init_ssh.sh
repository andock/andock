#!/usr/bin/env bash
set -e
# No encryption needed.
# Copy ssh keys.
cp id_rsa.pub ~/.ssh/id_rsa.pub
cp id_rsa ~/.ssh/id_rsa

cp authorized_keys ~/.ssh/authorized_keys

chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_rsa
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa
cat /etc/ssh/sshd_config
#mv -fv ssh-config ~/.ssh/config

