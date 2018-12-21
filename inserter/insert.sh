#!/bin/bash
set -e

if [ -z ${1+x} ]; then
  echo "Pass the name of the container you wish to insert into"
  exit 1
fi

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
  ${ROOT_DIR}/sh/tar_pipe_in.sh \
      ${arg} ${STORER_CONTAINER} ${KATAS_ROOT}
done

# - - - - - - - - - - - - - - - - - - - - - - - -
# set ownership of test-data in storer-container

docker exec \
  --user root \
  ${STORER_CONTAINER} \
    sh -c "chown -R storer:storer ${KATAS_ROOT}"
