#!/usr/bin/env sh
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-get -qq update;
sudo apt-get -y install cgroup-lite
sudo apt-get -y install docker-ce
sudo apt-get -y install snapd;
sudo snap install lxd;
sudo sh -c 'echo PATH=/snap/bin:$PATH >> /etc/environment';
while [ ! -S /var/snap/lxd/common/lxd/unix.socket ]; do echo "Waiting for LXD socket...";sleep 0.2;done;
sudo lxd init --auto;
sudo usermod -a -G lxd travis;


#sudo su travis -c 'lxc network create lxdbr0';
#sudo su travis -c 'lxc network attach-profile lxdbr0 default eth0';