#!/bin/bash

curl -O https://raw.githubusercontent.com/cyber-dojo/porter/master/port_cyber_dojo_storer_to_saver.sh
chmod 700 port_cyber_dojo_storer_to_saver.sh
docker pull cyberdojo/storer
docker pull cyberdojo/saver
docker pull cyberdojo/porter
sudo mkdir /cyber-dojo
sudo chown 19663:65533 /cyber-dojo
sudo mkdir /porter
sudo chown 19664:65533 /porter

# To extract an id2 subset...eg 02
docker run --detach -it --name temp --volumes-from cyber-dojo-katas-DATA-CONTAINER alpine sh
docker exec temp tar -c -f - -C /usr/src/cyber-dojo/katas 02 | tar -x -f - -C .
tar -zcf 02.tgz 02
docker rm -f temp

# to shell into a container that can see the data-container
docker run --rm -it --user storer --volumes-from cyber-dojo-katas-DATA-CONTAINER cyberdojo/storer sh
