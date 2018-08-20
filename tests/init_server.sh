#!/usr/bin/env sh
# Script creates a new test droplet and
# assigns an floating ip to the droplet

set -e

slug=$1

# Set default to "ubuntu-18-04-x64"
if [ "${slug}" = "" ]; then
    slug="ubuntu-18-04-x64"
fi

# Create new droplet.
echo "Create new droplet with image id: andock-travis-${slug}"
doctl_id=$(doctl compute droplet create "andock-travis-${slug}" --size 1gb --image ${slug} --region fra1 --ssh-keys b6:3c:4d:07:15:8c:7c:43:43:71:e3:61:a3:2d:f1:db,4b:df:d0:74:35:11:97:a7:93:87:a7:4a:b1:66:9b:a3 --wait --no-header --format ID)
doctl_ip=$(doctl compute droplet list "andock-travis-${slug}" --no-header --format="Public IPv4")
# Assign floating ip.
sudo touch /etc/hosts
sudo echo "dev.andock.ci ${doctl_ip}" > /etc/hosts
cat /etc/hosts
echo "YUUUPP! BAAAM!. Sleep for 5 minutes to be sure everything is up."
sleep 360