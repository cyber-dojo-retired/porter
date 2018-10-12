#!/bin/bash
set -e

# called from pipe_build_up_test.sh

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly KATA_IDS=(1F00C1BFC8 5A0F824303 420B05BA0A 420F2A2979 421F303E80 420BD5D5BE 421AFD7EC5)
readonly STORER_CONTAINER='test-storer-server'

# this must be set to the same value as Storer's path.
readonly CYBER_DOJO_KATAS_ROOT=/usr/src/cyber-dojo/katas

# - - - - - - - - - - - - - - - - - - - - - - - -
# make sure ${CYBER_DOJO_KATAS_ROOT} dir exists

docker exec \
  --user root \
  ${STORER_CONTAINER} \
    sh -c "mkdir -p ${CYBER_DOJO_KATAS_ROOT}"

# - - - - - - - - - - - - - - - - - - - - - - - -
# tar-pipe test data into storer-container

for KATA_ID in "${KATA_IDS[@]}"
do
  cat ${MY_DIR}/${KATA_ID}.tgz \
    | docker exec \
        --user root \
        --interactive \
        ${STORER_CONTAINER} \
            sh -c "tar -zxf - -C ${CYBER_DOJO_KATAS_ROOT}"
done

# - - - - - - - - - - - - - - - - - - - - - - - -
# set ownership of test-data in storer-container

docker exec \
    --user root \
    ${STORER_CONTAINER} \
      sh -c "chown -R storer:storer ${CYBER_DOJO_KATAS_ROOT}"
