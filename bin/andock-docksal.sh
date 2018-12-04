#!/bin/bash
ANDOCK_PROJECT_NAME=$(basename "$PWD")
cmd="andock"
if [[ $2 != "" ]]; then
	cmd="$cmd "$(printf " %q" "$@")
else
	cmd="$cmd $*"
fi

# Check if an andock container is configured. Otherwise install it inside the cli container.
service_name=$(fin ps | sed -n 's/\(.*\)_andock_1\(.*\)/\1/p')
if [[ ${service_name} != "" ]]; then
        export CONTAINER_NAME='andock'
        export container_user='-u docker'
    else
        export CONTAINER_NAME='cli'
fi

fin exec "
if [ ! -f \"/usr/local/bin/andock\" ]; then
 curl -fsSL https://raw.githubusercontent.com/andock/andock/master/install-andock | sh
fi
export ANDOCK_INSIDE_DOCKSAL=true
export ANDOCK_PROJECT_NAME=${ANDOCK_PROJECT_NAME}
$cmd"

