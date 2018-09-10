#!/usr/bin/env bats

# Run server.bats before.

load setup_helper


@test "fin init" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin init -e "branch=master"
    [ $status = 0 ]
}

@test "fin init: Testing page status" {
    run 'curl -sL -I http://master.demo-project.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "HTTP/1.1 201 OK" ]]
}

@test "fin init: Testing page content" {
    run 'curl -sL http://master.demo-project.dev.andock.ci | grep "Hello Andock"'
    [[ "$output" =~ "Hello Andock" ]]
}

@test "fin-run: Execute fin version" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin-run "version" -e "branch=master"
    [ $status = 0 ]
}

@test "fin up" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin up -e "branch=master"
    [ $status = 0 ]
}

@test "fin update" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin update -e "branch=master"
    [ $status = 0 ]
}

@test "fin test" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin test -e "branch=master"
    [ $status = 0 ]
}

@test "fin rm" {
  run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin rm -e "branch=master"
  [ $status = 0 ]
}

@test "fin rm: Testing page status" {
    run 'curl -sL -I http://master.demo-project.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "" ]]
}
