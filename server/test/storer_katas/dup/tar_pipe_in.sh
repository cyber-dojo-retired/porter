#!/bin/bash
set -e

# called from pipe_build_up_test.sh

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly KATA_IDS=(0BA7E1E01B 0BA7E16149 463748A0E8 463748D943)
readonly STORER_CONTAINER=${1:-test-porter-storer}

# this must be set to the same value as Storer's path.
readonly KATAS_ROOT=/usr/src/cyber-dojo/katas

# - - - - - - - - - - - - - - - - - - - - - - - -
# make sure ${KATAS_ROOT} dir exists

docker exec \
  --user root \
  ${STORER_CONTAINER} \
    sh -c "mkdir -p ${KATAS_ROOT}"

# - - - - - - - - - - - - - - - - - - - - - - - -
# tar-pipe test data in

for KATA_ID in "${KATA_IDS[@]}"
do
  cat ${MY_DIR}/${KATA_ID}.tgz \
    | docker exec \
        --user root \
        --interactive \
        ${STORER_CONTAINER} \
            sh -c "tar -zxf - -C ${KATAS_ROOT}"
done

# - - - - - - - - - - - - - - - - - - - - - - - -
# set ownership of test-data

docker exec \
    --user root \
    ${STORER_CONTAINER} \
      sh -c "chown -R storer:storer ${KATAS_ROOT}"
