#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

#${ROOT_DIR}/inserter/docker_build_image.sh

export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  build
