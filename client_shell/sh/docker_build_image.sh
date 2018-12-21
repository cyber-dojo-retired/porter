#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly IMAGE_NAME=${1}

docker build \
  --tag=${IMAGE_NAME} \
  --file=Dockerfile.storer-data-container \
  ${MY_DIR}
