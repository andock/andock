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

echo $(ssh -o BatchMode=yes -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no travis@localhost echo ok 2>&1)
echo $(ssh -o BatchMode=yes -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no travis@127.0.0.1 echo ok 2>&1)