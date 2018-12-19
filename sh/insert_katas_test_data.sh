#!/bin/bash
set -e

# https://github.com/cyber-dojo/inserter

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

# untar to test_data_storer_context
cd ${ROOT_DIR}/test_data_storer_context
tar -xf ${ROOT_DIR}/test_data_storer/dup/463748A0E8.tgz
tar -xf ${ROOT_DIR}/test_data_storer/dup/463748D943.tgz

# volume-mount in docker-compose.yml

sdfsdf

docker run \
   --rm -it \
   --volume /var/run/docker.sock:/var/run/docker.sock \
   cyberdojo/inserter \
     test-porter-storer \
       dup old new red
       # 7E 4D

# do few with volume-mount...
