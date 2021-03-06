#!/usr/bin/env sh
# Script creates a new test droplet and
# assigns an floating ip to the droplet

set -e

# Check if a droplet exists and if found delete it.
echo "Search for old droplet with name andock-travis"
old_doctl_id=$(doctl compute droplet list "andock-travis" --no-header --format=ID)
if [ "${old_doctl_id}" != "" ]; then
    echo "Old droplet found."
    echo "Delete droplet with id: ${old_doctl_id}..."
    doctl compute droplet delete ${old_doctl_id} -f
    echo "Deleting done."
fi
