#!/usr/bin/env sh
set -e

test_method=$1
image=$2

if [ "${test_method}" = "" ]; then
    test_method="lxd"
fi

cd ${test_method}


echo "Install $test_method components..."
./install.sh
echo "Initialize ssh configuration..."
./init_ssh.sh
echo "Start components..."
./init.sh $image



