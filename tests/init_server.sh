#!/usr/bin/env sh
# Script creates a new test droplet and
# assigns an floating ip to the droplet

set -e

slug=$1

# Set default to "ubuntu-18-04-x64"
if [ "${slug}" = "" ]; then
    slug="ubuntu-16-04-x64"
fi

# Check if a droplet exists and if found delete it.
echo "Search for old droplet with name andock-travis"
old_doctl_id=$(doctl compute droplet list 'andock-travis' --no-header --format=ID)
if [ "${old_doctl_id}" != "" ]; then
    echo "Old droplet found."
    echo "Restore droplet with id: ${old_doctl_id}..."
    doctl compute droplet-action restore ${old_doctl_id} --image-id 37399306 --wait
    echo "Restore done!"
    echo "Sleep for a minute and relaxe."
    sleep 60
fi

