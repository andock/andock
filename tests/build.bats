#!/usr/bin/env bats

# Run server.bats first.


load setup_helper

@test "build" {
  ../../bin/andock.sh "@${ANDOCK_CONNECTION}" build -e "branch=master"

  if [ "${ANDOCK_TEST_TYPE}" == "travis" ]; then
    ls /home/${ANDOCK_USER}/andock/projects/v1z2kdj/master/master-v1z2kdj__build/
  fi
}

@test "build deploy" {
  ../../bin/andock.sh "@${ANDOCK_CONNECTION}" build push -e "branch=master"

  if [ "${ANDOCK_TEST_TYPE}" == "travis" ]; then
    ls /home/${ANDOCK_USER}/andock/projects/v1z2kdj/master/master-v1z2kdj__build/
    ls /home/${ANDOCK_USER}/andock/projects/v1z2kdj/master/master-v1z2kdj__build/andock-stage
  fi

}

@test "build clean" {
  ../../bin/andock.sh "@${ANDOCK_CONNECTION}" build clean -e "branch=master"
  if [ "${ANDOCK_TEST_TYPE}" == "travis" ]; then
    run ls /home/${ANDOCK_USER}/andock/projects/v1z2kdj/master/master-v1z2kdj__build/
    [[ $status != 0 ]]
  fi

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