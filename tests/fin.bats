#!/usr/bin/env bats

# Run server.bats before.

setup() {
    cd demo-project
}

@test "fin init" {
    run ../../bin/andock.sh fin init -e "branch=master"
    [ $status = 0 ]
}

@test "fin init: Testing page status" {
    run 'curl -sL -I http://master.demo-project.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
}

@test "fin init: Testing page content" {
    run 'curl -sL http://master.demo-project.dev.andock.ci | grep "Hello Andock"'
    [[ "$output" =~ "Hello Andock" ]]
}

@test "fin update" {
    ../../bin/andock.sh fin update -e "branch=master"
}

@test "fin test" {
    ../../bin/andock.sh fin test -e "branch=master"
}

@test "fin rm" {
  ../../bin/andock.sh fin rm -e "branch=master"
}

@test "fin rm: Testing page status" {
    run 'curl -sL -I http://master.demo-project.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "" ]]
}
