#!/usr/bin/env sh


container_exists=$(lxc list| grep andock)

if [ "${container_exists}" != "" ]; then
    echo "Found existing andock container. Removing...."
    ./remove.sh
    echo "Removing done."
fi

set -e
echo "Launch container"
# Create container.
sudo lxc launch ubuntu-daily:18.04 andock -c security.nesting=true

echo "done. Sleep to be sure everything is up"
sleep 10
echo "Getting container ip..."
# Get ip.
andock_lxc_container_ip=$(sudo lxc list "andock" -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')

# Copy authorized key file and set permissions.
sudo lxc file push authorized_keys andock/root/.ssh/authorized_keys
sudo lxc exec andock -- chown root:root /root/.ssh/authorized_keys
sudo lxc exec andock -- chmod 600 /root/.ssh/authorized_keys
# Clean up local host.
sudo sed -i '/dev.andock.ci/d' /etc/hosts
# Update local hosts file.
    echo "
${andock_lxc_container_ip} dev.andock.ci" | sudo tee --append /etc/hosts

    echo "
${andock_lxc_container_ip} master.demo-project.dev.andock.ci" | sudo tee --append /etc/hosts

sudo cat /etc/hosts