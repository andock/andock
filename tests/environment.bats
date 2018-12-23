#!/usr/bin/env bats

# Run server.bats before.

load setup_helper


@test "deploy" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} deploy -e "branch=master"
    [ $status -eq 0 ]
}

@test "deploy: Testing page status" {
    run bash -c 'curl -sL -I "http://master.demo-project.dev.andock.ci" | grep "HTTP/1.1 404 Not Found"'
    [ $status -ne 0 ]
    run bash -c 'curl -sL -I "http://master.demo-project.dev.andock.ci" | grep "HTTP/1.1 200 OK")'
    [ $status -e 0 ]

}

@test "deploy: Testing page content" {
    run bash -c 'curl -sL http://master.demo-project.dev.andock.ci | grep "Hello Andock"'
    [ $status -e 0 ]
}

@test "url: Show url" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment url -e "branch=master"
    [ $status -e 0 ]
}

@test "fin: Execute fin version" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin "version" -e "branch=master"
    [ $status -e 0 ]
}

@test "up" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment up -e "branch=master"
    [ $status -e 0 ]
}

@test "test" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment test -e "branch=master"
    [ $status -e 0 ]
}

@test "rm" {
  run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment rm -e "branch=master"
  [ $status -e 0 ]
}

@test "rm: Testing page status" {
    run bash -c 'curl -sL -I "http://master.demo-project.dev.andock.ci" | grep "HTTP/1.1 200 OK")'
    [ $status -ne 0 ]
    run bash -c 'curl -sL -I "http://master.demo-project.dev.andock.ci" | grep "HTTP/1.1 404 Not Found"'
    [ $status = 0 ]
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