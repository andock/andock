#!/usr/bin/env sh
# exit on fail
# setup LXD group
sudo groupadd --system lxd
sudo usermod -a -G lxd $USER
sudo apt-get -qq update;
sudo apt-get -y install snapd;
sudo snap install lxd;
sudo sh -c 'echo PATH=/snap/bin:$PATH >> /etc/environment';

sudo lxd waitready
printf 'n\ny\ndefault\ndir\nn\ny\nlxdbr0\nauto\nauto\ny\nall\n\ny\nn\n' | sudo lxd init
sudo lxd.lxc profile set travis security.privileged true
sudo lxd.lxc profile copy default travis

#sudo su travis -c 'lxc network create lxdbr0';
#sudo su travis -c 'lxc network attach-profile lxdbr0 default eth0';
