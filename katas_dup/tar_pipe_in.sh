#!/bin/bash
set -e

# called from pipe_build_up_test.sh

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly KATA_IDS=(0BA7E1E01B 0BA7E16149 463748A0E8 463748D943)
readonly STORER_CONTAINER='test-porter-storer'

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
