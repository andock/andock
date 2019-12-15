#!/usr/bin/env bash
set -e

git -C test-project pull || git clone https://github.com/andock/test-project.git

mkdir -p ~/.andock
cp version ~/.andock/version
bats environment.bats

