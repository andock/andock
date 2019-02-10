#!/usr/bin/env bash

#cd digitalocean
#./create_droplet.sh
#cd ..
cd boilerplate-drupal8
#andock server install
#andock build deploy
cd web
#fin drush sql-sync --local @demo-drupal.master @self -y
ssh andock@dev.andock.ci "
docker stop andock-ssh2docksal || true && docker rm andock-ssh2docksal || true"
ssh andock@dev.andock.ci 'docker run \
-d \
-e "HOST_UID=$(id -u)" \
-e "HOST_GID=$(cut -d: -f3 < <(getent group docker))" \
--restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/bin/docker:/usr/bin/docker \
-v /home/andock/.ssh/authorized_keys:/home/docker/.ssh/authorized_keys:rw \
--name andock-ssh2docksal \
-p 0.0.0.0:2222:2222 andockio/ssh2docksal:1.0-rc.2 --verbose'
fin drush sql-sync --local @demo-drupal.master @self -y

ssh andock@dev.andock.ci "docker logs andock-ssh2docksal"
