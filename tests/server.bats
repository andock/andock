#!/usr/bin/env bats

setup() {
  cd demo-project
}

@test "connect" {
  ../../bin/andock.sh connect "default" "dev.andock.ci"
}

@test "server:install" {
  ../../bin/andock.sh server:install "andock" "root"
}

@test "server:update" {
  ../../bin/andock.sh server:update "andock"
}

@test "server:ssh-add" {
  ../../bin/andock.sh server:ssh-add "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRSp8EAEXfDN5zLpGX15OlFE33dXW6eGn53ZLQR28liRkSvP+y7vDnBzIQj7WmgomG3unVUvhPVrF27W7j9DRK67wog9XTTeXKVTaT63b3v0TYTVmAYPlE15ArOfZvUaq8LM44Hs6P5+L6DngZm3fbgdNKsPXmizQ7CxciRciV6wxrwAgkUW9100CUFgEOnf4+B8Nbj3VZl2iKL3DZzfTYNENFl21yK+tMo7oMsyhyra5fwj/A4Gqj7nL2MESBdHw7YZ5r3FO8+rc+dwiOTcc1ATRrwsGXsuEXg1VGo8TBTvkXkD59J8FmZV8qlewxTpqwW2yveuNSZenC5tpL5TT/ deploy@travis-ci.org"
}
