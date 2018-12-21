#!/bin/bash
set -e

readonly IMAGE_NAME=${1}
readonly DATA_CONTAINER_NAME=${2}

docker create \
  --name ${DATA_CONTAINER_NAME} \
  ${IMAGE_NAME} \
  "echo 'cdfKatasDC' > /dev/null"
