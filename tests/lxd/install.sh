#!/usr/bin/env sh
sudo apt-get -y install snapd;
sudo snap install lxd;
sudo sh -c 'echo PATH=/snap/bin:$PATH >> /etc/environment';
while [ ! -S /var/snap/lxd/common/lxd/unix.socket ]; do echo "Waiting for LXD socket...";sleep 0.2;done;
sudo lxd init --auto;
sudo usermod -a -G lxd travis;
sudo apt-get -y install cgroup-lite

#sudo su travis -c 'lxc network create lxdbr0';
#sudo su travis -c 'lxc network attach-profile lxdbr0 default eth0';