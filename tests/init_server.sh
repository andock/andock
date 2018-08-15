#!/usr/bin/env bash
# Script creates a new test droplet and
# assigns an floating ip to the droplet

set -e

slug=$1

# Set default to "ubuntu-18-04-x64"
if [ "${slug}" == "" ]; then
    slug="ubuntu-18-04-x64"
fi

# Check if a droplet exists and if found delete it.
echo "Search for old droplet with name andock-travis"
old_doctl_id=$(doctl compute droplet list 'andock-travis' --no-header --format=ID)
if [ "${old_doctl_id}" != "" ]; then
    echo "Old droplet found."
    echo "Delete droplet with id: ${old_doctl_id}..."
    doctl compute droplet delete andock-travis -f
    echo "Deleting done."
fi

# Create new droplet.
echo "Create new droplet with image id: ${slug}"
doctl_id=$(doctl compute droplet create andock-travis --size 1gb --image ${slug} --region fra1 --ssh-keys b6:3c:4d:07:15:8c:7c:43:43:71:e3:61:a3:2d:f1:db,4b:df:d0:74:35:11:97:a7:93:87:a7:4a:b1:66:9b:a3 --wait --no-header --format ID)
echo "Droplet was created successfully. ID: ${doctl_id}"
# Assign floating ip.
echo "Assign floating ip."
doctl compute floating-ip-action assign 138.68.112.178 ${doctl_id}

# There seems to be no way to wait till the ip is assigned
# @TODO: Find better way.
echo "YUUUPP! BAAAM!. Sleep for 60 to be sure everything is up."
sleep 60