#!/usr/bin/env sh


container_exists=$(sudo lxc list| grep andock)

if [ "${container_exists}" != "" ]; then
    echo "Found existing andock container. Removing...."
    ./remove.sh
    echo "Removing done."
fi

set -e
echo "Launch container"
# Create container.
sudo lxc launch ubuntu-daily:18.04 andock -c security.privileged=true -c security.nesting=true

echo "done. Sleep to be sure everything is up"
sleep 10
echo "Getting container ip..."
# Get ip.
andock_lxc_container_ip=$(sudo lxc list "andock" -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')

# Copy authorized key file and set permissions.
sudo lxc file push authorized_keys andock/root/.ssh/authorized_keys
sudo lxc exec andock -- chown root:root /root/.ssh/authorized_keys
sudo lxc exec andock -- chmod 600 /root/.ssh/authorized_keys

if [ "${TRAVIS}" = "true" ]; then
    sudo lxc exec andock -- mount -o remount,rw /sys/fs/cgroup/
    sudo lxc exec andock -- mkdir /sys/fs/cgroup/cpu
    sudo lxc exec andock -- mkdir /sys/fs/cgroup/cpuacct
    sudo lxc exec andock -- mkdir /sys/fs/cgroup/net_cls
    sudo lxc exec andock -- mkdir /sys/fs/cgroup/net_prio
    sudo lxc exec andock -- mount -t cgroup cgroup -o cpu /sys/fs/cgroup/cpu
    sudo lxc exec andock -- mount -t cgroup cgroup -o cpuacct /sys/fs/cgroup/cpuacct
    sudo lxc exec andock -- mount -t cgroup cgroup -o net_cls /sys/fs/cgroup/net_cls
    sudo lxc exec andock -- mount -t cgroup cgroup -o net_prio /sys/fs/cgroup/net_prio
fi

# Clean up local host.
sudo sed -i '/dev.andock.ci/d' /etc/hosts
# Update local hosts file.
    echo "
${andock_lxc_container_ip} dev.andock.ci" | sudo tee --append /etc/hosts

    echo "
${andock_lxc_container_ip} master.demo-project.dev.andock.ci" | sudo tee --append /etc/hosts

sudo cat /etc/hosts