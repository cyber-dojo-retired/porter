#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly STORER_CONTAINER=${1}
readonly KATAS_ROOT=${2}
readonly KATA_IDS=( \
    463748A0E8 \
    463748D943 )

# - - - - - - - - - - - - - - - - - - - - - - - -

echo "inserting duplicate katas into ${STORER_CONTAINER}"
for KATA_ID in "${KATA_IDS[@]}"
do
  echo "...${KATA_ID}"
  cat ${MY_DIR}/${KATA_ID}.tgz \
    | docker exec \
        --user root \
        --interactive \
        ${STORER_CONTAINER} \
            sh -c "tar -zxf - -C ${KATAS_ROOT}"
done