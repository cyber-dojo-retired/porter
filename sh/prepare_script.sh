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

06FDEDE8F6
sudo mv 0C51B7D2A0 ../raised-ids/
sudo mv 13FD5799F0 ../raised-ids/
sudo mv 20991D5E5D ../raised-ids/
sudo mv 22C5EC4025 ../raised-ids/
sudo mv 23537EB9F5 ../raised-ids/
sudo mv 2C37C674C7 ../raised-ids/
sudo mv 3A1A9C317D ../raised-ids/
sudo mv 4767DF561B ../raised-ids/
sudo mv 50F7CB1888 ../raised-ids/
sudo mv 5E8808DCA2 ../raised-ids/
sudo mv 67C35468AE ../raised-ids/
sudo mv 74E8A52998 ../raised-ids/
sudo mv 7F70CE1780 ../raised-ids/
sudo mv 8635C75996 ../raised-ids/
sudo mv 8FA5A0F3F8 ../raised-ids/
sudo mv 98E4C6CC89 ../raised-ids/
sudo mv B8F2F1171A ../raised-ids/
sudo mv BDAD5039F5 ../raised-ids/
sudo mv C63D823021 ../raised-ids/
sudo mv CBBA2E0A26 ../raised-ids/
sudo mv E37CFB3C22 ../raised-ids/
sudo mv E74CB83662 ../raised-ids/
sudo mv EFE7C7A2DD ../raised-ids/
sudo mv FA127F1F59 ../raised-ids/
