#!/usr/bin/env bats

# Run server.bats before.

load setup_helper


@test "deploy" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} :master deploy
    [[ $status == 0 ]]
}

@test "deploy: Testing page status" {
    run curl -sL -I "http://master.demo-project.dev.andock.ci"
    echo $output | grep "HTTP/1.1 200 OK"
    unset output

}

@test "deploy: Testing page content" {
    run curl -sL http://master.demo-project.dev.andock.ci
    echo $output | grep "Hello Andock"
    unset output
}

@test "url: Show url" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} :master  environment url
    [[ $status == 0 ]]
}

@test "fin: Execute fin version" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} :master fin "version"
    [[ $status == 0 ]]
}

@test "status" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} :master  environment status
    [[ $status == 0 ]]
}

@test "up" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} :master environment up
    [[ $status == 0 ]]
}

@test "test" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} :master  environment test
    [[ $status == 0 ]]
}

@test "rm" {
  run ../../bin/andock.sh @${ANDOCK_CONNECTION} :master environment rm
  [[ $status == 1 ]]
}

@test "rm --force" {
  run ../../bin/andock.sh @${ANDOCK_CONNECTION} :master  environment rm --force
  [[ $status == 0 ]]
}

@test "rm: Testing page status" {
    run curl -sL -I "http://master.demo-project.dev.andock.ci"
    echo "$output" | grep "HTTP/1.1 404 Not Found"
    unset output
}

@test "build deploy" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} :master  build deploy
    [[ $status == 0 ]]
    run curl -sL http://master.demo-project.dev.andock.ci
    echo $output | grep "Hello Andock"
    unset output
}


@test "rm" {
  run ../../bin/andock.sh @${ANDOCK_CONNECTION} :master environment rm --force
  [[ $status == 0 ]]
  fin rm -f
  [[ $status == 0 ]]
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