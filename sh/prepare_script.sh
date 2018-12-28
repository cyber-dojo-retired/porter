#!/bin/bash

curl -O https://raw.githubusercontent.com/cyber-dojo/porter/master/port_cyber_dojo_storer_to_saver.sh
chmod 700 port_cyber_dojo_storer_to_saver.sh
docker pull cyberdojo/storer
docker pull cyberdojo/saver
docker pull cyberdojo/porter
sudo chown 19663:65533 /cyber-dojo
sudo chown 19664:65533 /porter


# Used to look at specific id10's in DC after a port run...
docker run --rm -it --volumes-from cyber-dojo-katas-DATA-CONTAINER alpine sh
