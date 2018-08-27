#!/usr/bin/env sh
set -e

test_method=$1
image=$2

if [ "${test_method}" = "" ]; then
    test_method="lxd"
fi

ssh-keygen -f "/home/cw/.ssh/known_hosts" -R "dev.andock.ci"

cd ${test_method}
#./install.sh
#./init_ssh.sh
./init.sh $image


