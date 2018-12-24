#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly STORER_CONTAINER=${1}
readonly KATAS_ROOT=${2}
readonly KATA_IDS=( \
  1F00C1BFC8 \
  5A0F824303 \
  420B05BA0A \
  420F2A2979 \
  421F303E80 \
  420BD5D5BE \
  421AFD7EC5 )

for KATA_ID in "${KATA_IDS[@]}"
do
  cat ${MY_DIR}/${KATA_ID}.tgz \
    | docker exec \
        --user root \
        --interactive \
        ${STORER_CONTAINER} \
            sh -c "tar -zxf - -C ${KATAS_ROOT}"
done
