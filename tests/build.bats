#!/usr/bin/env bats

# Run server.bats first.


load setup_helper

@test "build" {
  ../../bin/andock.sh "@${ANDOCK_CONNECTION}" build -e "branch=master"
}

@test "Check build folder" {
  if [ "${ANDOCK_TEST_TYPE}" != "travis" ]; then
    skip "Skip test for non local connections"
  fi
  ls /home/andock/andock/projects/mp4yqom/master/master-mp4yqom__build/
}

@test "build clean" {
  ../../bin/andock.sh "@${ANDOCK_CONNECTION}" build clean -e "branch=master"
}

@test "Check build folder not exits" {
  if [ "${ANDOCK_TEST_TYPE}" != "travis" ]; then
    skip "Skip test for non local connections"
  fi
  run ls /home/andock/andock/projects/mp4yqom/master/master-mp4yqom__build/
  [[ $status != 0 ]]
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