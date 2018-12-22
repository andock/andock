#!/usr/bin/env bats

# Run server.bats before.

setup() {
    cd demo-drupal
    if [ "${ANDOCK_CONNECTION}" = "" ]; then
        export ANDOCK_CONNECTION="default"
    fi

    if [ "${ANDOCK_ROOT_USER}" = "" ]; then
        export ANDOCK_ROOT_USER="root"
    fi
}


@test "build drupal" {
    git checkout master
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} build -e "branch=master"
    [ $status = 0 ]
}
@test "deploy drupal" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} deploy -e "branch=master"
    [ $status = 0 ]
}

@test "Check fresh installed site" {
    local output && output=$(curl -sL -I -k "https://www.master.demo-drupal.dev.andock.ci" | grep "HTTP/2 200")
    [ ! -z "$output" ]
}

@test "drush sql-sync test" {
    cd web
    fin ssh-key add id_rsa
    fin drush sa

    run fin drush sql-sync --local @self @demo-drupal.master -y
    [ $status = 0 ]
    run fin drush sql-sync --local @demo-drupal.master @self -y
    [ $status = 0 ]
}

@test "Site still still works?" {
    local output && output=$(curl -sL -I -k "https://www.master.demo-drupal.dev.andock.ci" | grep "HTTP/2 200")
    [ ! -z "$output" ]
}

@test "Setup dev environment" {
    cd web
    git checkout develop
    run ../../../bin/andock.sh @${ANDOCK_CONNECTION} build -e "branch=develop"
    [ $status = 0 ]
    run ../../../bin/andock.sh @${ANDOCK_CONNECTION} deploy -e "branch=develop"
    [ $status = 0 ]

}
@test "Check dev environment" {
    local output && output=$(curl -sL -I -k "https://www.develop${ANDOCK_TEST_SUFFIX}.demo-drupal.dev.andock.ci" | grep "HTTP/2 200")
    [ ! -z "$output" ]
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