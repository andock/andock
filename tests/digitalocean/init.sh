#!/usr/bin/env sh
# Script creates a new test droplet and
# assigns an floating ip to the droplet

set -e

slug=$1

# Set default to "ubuntu-18-04-x64"
if [ "${slug}" = "" ]; then
    slug="ubuntu-18-04-x64"
    else
    shift
fi

assign_ip=$1

./cleanup.sh $slug

# Create new droplet.
echo "Create new droplet with image id: andock-travis-${slug}"
doctl_id=$(doctl compute droplet create "andock-travis-${slug}" --size 1gb --image ${slug} --region fra1 --ssh-keys b6:3c:4d:07:15:8c:7c:43:43:71:e3:61:a3:2d:f1:db,4b:df:d0:74:35:11:97:a7:93:87:a7:4a:b1:66:9b:a3 --wait --no-header --format ID)
doctl_ip=$(doctl compute droplet list "andock-travis-${slug}" --no-header --format="Public IPv4")

if [ "${assign_ip}" = "true" ]; then
    # Assign floating ip.
    echo "Assign floating ip."
    doctl compute floating-ip-action assign 138.68.112.178 ${doctl_id}
else
    echo "
${doctl_ip} dev.andock.ci" | sudo tee --append /etc/hosts

    echo "
${doctl_ip} master.demo-project.dev.andock.ci" | sudo tee --append /etc/hosts
    sudo cat /etc/hosts
fi


echo "Sleep for 2 minutes to be sure everything is up."
sleep 120