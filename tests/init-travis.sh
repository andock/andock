#!/usr/bin/env sh
set -e

test_method=$1
image=$2

if [ "${test_method}" = "" ]; then
    test_method="vagrant"
fi

cd ${test_method}

mkdir -p ~/.andock
cp andock.env ~/.andock/andock.env
echo "Install $test_method components..."
./install.sh
echo "Initialize ssh configuration..."
./init_ssh.sh
echo "Start components..."
./init.sh $image "true"



