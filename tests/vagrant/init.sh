#!/usr/bin/env sh
# Clean up local host.
sudo sed -i '/dev.andock.ci/d' /etc/hosts

    # Update local hosts file.
    echo "
192.168.33.10    dev.andock.ci" | sudo tee --append /etc/hosts

    echo "
192.168.33.10   master.demo-project.dev.andock.ci" | sudo tee --append /etc/hosts

sudo cat /etc/hosts

vagrant up