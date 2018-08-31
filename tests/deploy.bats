#!/usr/bin/env bats

# Run server.bats before.

setup() {
    cd demo-project
}

@test "deploy" {
    run ../../bin/andock.sh deploy -e "branch=master"
    [ $status = 0 ]
}

@test "deploy: Testing page status" {
    run 'curl -sL -I http://master.demo-project.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
}

@test "deploy: Testing page content" {
    run 'curl -sL http://master.demo-project.dev.andock.ci | grep "Hello Andock"'
    [[ "$output" =~ "Hello Andock" ]]
}

@test "fin rm" {
  ../../bin/andock.sh fin rm -e "branch=master"
}

@test "fin rm: Testing page status" {
    run 'curl -sL -I http://master.demo-project.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "" ]]
}
