#!/bin/bash
set -e

readonly STORER_CONTAINER=test-porter-storer

echo -n "Inserting test-data into ${STORER_CONTAINER}"

docker run \
   --rm \
   -it \
   --volume /var/run/docker.sock:/var/run/docker.sock \
   cyberdojo/inserter \
     ${STORER_CONTAINER} \
       red
       # dup_server old new throws
       # 02 7E 4D
echo 'OK'
