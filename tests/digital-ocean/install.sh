#!/usr/bin/env sh

curl -sL https://github.com/digitalocean/doctl/releases/download/v1.7.2/doctl-1.7.2-linux-amd64.tar.gz | tar -xzv
sudo mv doctl /usr/local/bin
doctl auth init -t $do_token
