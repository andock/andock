#!/usr/bin/env bats

# Run server.bats first.


load setup_helper

@test "build" {
  ../../bin/andock.sh @${ANDOCK_CONNECTION} build -e "branch=master"
}

load teardown_helper
