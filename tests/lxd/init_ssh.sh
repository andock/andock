#!/usr/bin/env bash
set -e
# No encryption needed.
# Copy ssh keys.
cp id_rsa.pub ~/.ssh/id_rsa.pub
cp id_rsa ~/.ssh/id_rsa

chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa
mv -fv ssh-config ~/.ssh/config