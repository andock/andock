#!/usr/bin/env bats

# Run server.bats first.


load setup_helper

@test "build" {
  ../../bin/andock.sh "@${ANDOCK_CONNECTION}" build -e "branch=master"
}

@test "build clean" {
  ../../bin/andock.sh "@${ANDOCK_CONNECTION}" build clean -e "branch=master"
}
teardown() {
    echo "Status: $status"
    echo "Output:"
    echo "================================================================"
    for line in "${lines[@]}"; do
        echo $line
    done
    echo "================================================================"
}