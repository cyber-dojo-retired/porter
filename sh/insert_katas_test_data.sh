#!/bin/bash
set -e

docker run \
   --rm \
   -it \
   --volume /var/run/docker.sock:/var/run/docker.sock \
   cyberdojo/storer-inserter \
     test-porter-storer \
       dup_server old new red
       # 7E 4D
