#!/usr/bin/env bats

# Run server.bats before.

setup() {
    cd demo-project
}

@test "build" {
  ../../bin/andock.sh build -e "branch=master"
}

