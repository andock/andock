#!/bin/bash

docksal_env=.docksal/docksal.env
if test -f "$docksal_env"; then
    source $docksal_env
fi

docksal_local_env=.docksal/docksal.local.env
if test -f "$docksal_local_env"; then
    source $ddocksal_local_env
fi

docksal_global_env=.docksal/docksal.env
if test -f "$docksal_global_env"; then
    source $docksal_global_env
fi

if [[ $ANDOCK_VERSION == "" ]]; then
  ANDOCK_VERSION="latest"
fi
echo "Use Andock Image $ANDOCK_VERSION"

fin rc --image=andockio/andock:$ANDOCK_VERSION andock $*
