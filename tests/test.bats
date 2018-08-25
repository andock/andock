#!/usr/bin/env bats


@test "fin init: Testing page status" {
    run 'curl -sL -I http://master.demo-project.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
}


