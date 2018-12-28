#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly STORER_CONTAINER=${1}
readonly KATAS_ROOT=/usr/src/cyber-dojo/katas
shift

# - - - - - - - - - - - - - - - - - - - - - - - -
# make sure ${KATAS_ROOT} dir exists in storer-container

docker exec \
  --user root \
  ${STORER_CONTAINER} \
    sh -c "mkdir -p ${KATAS_ROOT}"

# - - - - - - - - - - - - - - - - - - - - - - - -
# tar pipe specified test-data into storer-container

for arg in $@
do
  ${ROOT_DIR}/${arg}/tar_pipe_in.sh \
      ${STORER_CONTAINER} ${KATAS_ROOT}
done
