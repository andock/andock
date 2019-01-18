#!/usr/bin/env bats

# Run server.bats before.

setup() {
    cd boilerplate-drupal8


    if [ "${ANDOCK_CONNECTION}" = "" ]; then
        export ANDOCK_CONNECTION="default"
    fi

    if [ "${ANDOCK_ROOT_USER}" = "" ]; then
        export ANDOCK_ROOT_USER="root"
    fi
}

@test "build drupal" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} build deploy -e "branch=master"
    [ $status = 0 ]
}
@test "deploy drupal" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} deploy -e "branch=master"
    [ $status = 0 ]
    run curl -sL -I -k "https://www.master.demo-drupal.dev.andock.ci"
    echo "$output" | grep "HTTP/1.1 200 OK"
    unset output
}
@test "update letsencrypt certificate" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment letsencrypt -e "branch=master"
    [ $status = 0 ]
    run curl -sL -I -k "https://www.master.demo-drupal.dev.andock.ci"
    echo "$output" | grep "HTTP/1.1 200 OK"
    unset output
}

@test "drush sql-sync test" {
    #skip "Timeout problems. Skip for now"
    cd web
    fin ssh-key add id_rsa
    fin drush sa
    ssh andock@dev.andock.ci docker logs andock-ssh2docksal

    fin drush sql-sync --local @self @demo-drupal.master -y
    ssh andock@dev.andock.ci docker logs andock-ssh2docksal

    fin drush sql-sync --local @demo-drupal.master @self -y
    ssh andock@dev.andock.ci docker logs andock-ssh2docksal

    run curl -sL -I -k "https://www.master.demo-drupal.dev.andock.ci"
    echo "$output" | grep "HTTP/1.1 200 OK"
    unset output

}

@test "Build dev environment" {
    cd web
    git checkout develop
    run ../../../bin/andock.sh @${ANDOCK_CONNECTION} build deploy -e "branch=develop"
    [ $status = 0 ]
}

@test "Deploy dev environment" {
    cd web
    run ../../../bin/andock.sh @${ANDOCK_CONNECTION} deploy -e "branch=develop"
    [ $status = 0 ]
    run curl -sL -I -k "https://www.develop.demo-drupal.dev.andock.ci"
    echo "$output" | grep "HTTP/1.1 200 OK"
    unset output

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