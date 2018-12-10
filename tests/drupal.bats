#!/usr/bin/env bats

# Run server.bats before.

load setup_helper_drupal


@test "build drupal" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin build -e "branch=master"
    [ $status = 0 ]
}
@test "deploy drupal" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin deploy -e "branch=master"
    [ $status = 0 ]
}

@test "deploy: Testing page status" {
    run 'curl -sL -I https://master.demo-drupal.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
}

@test "drush sql-sync @elf @remote" {
    cd web
    run fin drush sql-sync @self @demo-drupal.master -y
    [ $status = 0 ]
}

@test "deploy: Testing page status" {
    run 'curl -sL -I https://master.demo-drupal.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
}

@test "drush sql-sync @remote @elf" {
    cd web
    run fin drush sql-sync @demo-drupal.master @self -y
    [ $status = 0 ]
}

@test "deploy: Testing page status" {
    run 'curl -sL -I https://master.demo-drupal.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
}

@test "Setup dev environment" {
    cd web
    git checkout develop
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin build -e "branch=develop"
    [ $status = 0 ]
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin deploy -e "branch=develop"
    [ $status = 0 ]
}