#!/usr/bin/env bats


@test "init" {
    export ANSIBLE_SSH_PIPELINING=True
    run ansible-playbook -i inventory-localhost default.yml --tags init
    [ $status = 0 ]
    # Check folder
    run ls -al ~/andock/projects/test-project
    [ $status = 0 ]
    run ls -al ~/andock/projects/test-project/master
    [ $status = 0 ]
    run ls -al ~/andock/projects/test-project/master/master-test-project
    [ $status = 0 ]
    run touch ~/andock/projects/test-project/master/master-test-project/docroot/files/test.txt;
    [ $status = 0 ]
    run touch ~/andock/projects/test-project/master/master-test-project/docroot/test.txt;
    [ $status != 0 ]
}

@test "Update" {
    export ANSIBLE_SSH_PIPELINING=True
    run ansible-playbook -i inventory-localhost default.yml --tags update
    [ $status = 0 ]
    run touch ~/andock/projects/test-project/master/master-test-project/docroot/files/test.txt;
    [ $status = 0 ]
    run touch ~/andock/projects/test-project/master/master-test-project/docroot/test.txt;
    [ $status != 0 ]

}

@test "Remove" {
    export ANSIBLE_SSH_PIPELINING=True
    run ansible-playbook -i inventory-localhost default.yml --tags rm
    [ $status != 0 ]
    run ls -al ~/andock/projects/test-project/master/master-test-project
    [ $status = 0 ]
}

@test "Remove --force" {
    export ANSIBLE_SSH_PIPELINING=True
    run ansible-playbook -i inventory-localhost default.yml --tags rm -e "{'force_rm': true}"
    [ $status = 0 ]
    run ls -al ~/andock/projects/test-project/master/master-test-project
    [ $status != 0 ]
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