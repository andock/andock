#!/usr/bin/env bats

# Run server.bats before.

setup() {
    cd demo-project
}

@test "fin:init" {
  ../../bin/andock.sh fin init -e "branch=master"
}

@test "fin:update" {
  ../../bin/andock.sh fin update -e "branch=master"
}

@test "fin:test" {
  ../../bin/andock.sh fin test -e "branch=master"
}

@test "fin:rm" {
  ../../bin/andock.sh fin rm -e "branch=master"
}
