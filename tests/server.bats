#!/usr/bin/env bats

load setup_helper

@test "connect" {
  ../../bin/andock.sh connect "default" "dev.andock.ci"
}

@test "server:install" {
  ../../bin/andock.sh @${ANDOCK_CONNECTION} server:install "andock" "${ANDOCK_ROOT_USER}" -e "sudo_nopasswd=true"
}
@test "SSH connect to localhost" {
  if [ "${ANDOCK_CONNECTION}" = "local" ]; then
    skip "Skip test for non local connections"
  fi
  echo $(ssh -o BatchMode=yes -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no andock@dev.andock.ci echo ok 2>&1)
}

@test "Check docksal.env file " {
  if [ "${ANDOCK_CONNECTION}" != "travisssh" ]; then
    skip "Skip test for non local connections"
  fi
  cd /home/andock
  run stat .docksal/docksal.env
  [ $status = 0 ]
}

@test "Check stacks folder" {
  if [ "${ANDOCK_CONNECTION}" != "travisssh" ]; then
    skip "Skip test for non local connections"
  fi
  cd /home/andock
  run stat .docksal/stacks
  [ $status = 0 ]
}

@test "Check authorized_keys file" {
  if [ "${ANDOCK_CONNECTION}" != "travisssh" ]; then
    skip "Skip test for non local connections"
  fi
  cd /home/andock
  run sudo stat .ssh/authorized_keys
  [ $status = 0 ]
}

@test "Check fin version" {
  if [ "${ANDOCK_CONNECTION}" != "travisssh" ]; then
    skip "Skip test for non local connections"
  fi
  cd /home/andock
  run sudo su andock -c 'fin version'
  [ $status = 0 ]
}


@test "server:update" {
  ../../bin/andock.sh @${ANDOCK_CONNECTION} server:update "andock" "${ANDOCK_ROOT_USER}" -e "sudo_nopasswd=true"
}

@test "server:ssh-add" {
  if [ "${ANDOCK_CONNECTION}" = "local" ]; then
    skip "not working for local connections"
  fi

  ../../bin/andock.sh @${ANDOCK_CONNECTION} server:ssh-add "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRSp8EAEXfDN5zLpGX15OlFE33dXW6eGn53ZLQR28liRkSvP+y7vDnBzIQj7WmgomG3unVUvhPVrF27W7j9DRK67wog9XTTeXKVTaT63b3v0TYTVmAYPlE15ArOfZvUaq8LM44Hs6P5+L6DngZm3fbgdNKsPXmizQ7CxciRciV6wxrwAgkUW9100CUFgEOnf4+B8Nbj3VZl2iKL3DZzfTYNENFl21yK+tMo7oMsyhyra5fwj/A4Gqj7nL2MESBdHw7YZ5r3FO8+rc+dwiOTcc1ATRrwsGXsuEXg1VGo8TBTvkXkD59J8FmZV8qlewxTpqwW2yveuNSZenC5tpL5TT/ deploy@travis-ci.org"
}

load teardown_helper