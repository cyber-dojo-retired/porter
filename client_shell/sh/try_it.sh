#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly IMAGE_NAME=${1:-bi}
readonly DATA_CONTAINER_NAME=${2:-bidc}

${MY_DIR}/docker_build_volumed_image.sh ${IMAGE_NAME}
${MY_DIR}/docker_create_data_container.sh ${IMAGE_NAME} ${DATA_CONTAINER_NAME}

# demo
docker run --rm -it \
  --volumes-from ${DATA_CONTAINER_NAME} \
  alpine sh -c 'ls -al /usr/src/cyber-dojo/katas'
