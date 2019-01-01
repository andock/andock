#!/usr/bin/env bats

load setup_helper

@test "connect" {
  ../../bin/andock.sh connect "default" "dev.andock.ci"
}

@test "server:install" {
  ../../bin/andock.sh @${ANDOCK_CONNECTION} server install "andock" "${ANDOCK_ROOT_USER}" -e "andock_user=${ANDOCK_USER}"
}

@test "Check docksal.env file " {
  if [ "${ANDOCK_TEST_TYPE}" != "travis" ]; then
    skip "Skip test for non local connections"
  fi
  cd /home/${ANDOCK_USER}
  run stat .docksal/docksal.env
  [ $status = 0 ]
}

@test "Check stacks folder" {
  if [ "${ANDOCK_TEST_TYPE}" != "travis" ]; then
    skip "Skip test for non local connections"
  fi
  cd /home/${ANDOCK_USER}
  run stat .docksal/stacks
  [ $status = 0 ]
}

@test "Check authorized_keys file" {
  if [ "${ANDOCK_TEST_TYPE}" != "travis" ]; then
    skip "Skip test for non local connections"
  fi
  cd /home/${ANDOCK_USER}
  run sudo stat .ssh/authorized_keys
  [ $status = 0 ]
}

@test "Check fin version" {
  if [ "${ANDOCK_TEST_TYPE}" != "travis" ]; then
    skip "Skip test for non local connections"
  fi
  fin version
}


@test "server:update" {
  ../../bin/andock.sh @${ANDOCK_CONNECTION} server update "andock" "${ANDOCK_ROOT_USER}" -e "andock_user=${ANDOCK_USER}"
}

@test "server:ssh-add" {
  if [ "${ANDOCK_TEST_TYPE}" = "travis" ]; then
    skip "Skip test for local connections"
  fi
  ../../bin/andock.sh @${ANDOCK_CONNECTION} server ssh-add "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRSp8EAEXfDN5zLpGX15OlFE33dXW6eGn53ZLQR28liRkSvP+y7vDnBzIQj7WmgomG3unVUvhPVrF27W7j9DRK67wog9XTTeXKVTaT63b3v0TYTVmAYPlE15ArOfZvUaq8LM44Hs6P5+L6DngZm3fbgdNKsPXmizQ7CxciRciV6wxrwAgkUW9100CUFgEOnf4+B8Nbj3VZl2iKL3DZzfTYNENFl21yK+tMo7oMsyhyra5fwj/A4Gqj7nL2MESBdHw7YZ5r3FO8+rc+dwiOTcc1ATRrwsGXsuEXg1VGo8TBTvkXkD59J8FmZV8qlewxTpqwW2yveuNSZenC5tpL5TT/ deploy@travis-ci.org"
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