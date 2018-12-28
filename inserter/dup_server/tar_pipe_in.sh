#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly STORER_CONTAINER=${1}
readonly KATAS_ROOT=${2}
readonly KATA_IDS=( \
    463748A0E8 \
    463748D943 )

for KATA_ID in "${KATA_IDS[@]}"
do
  echo -n '.'
  cat ${MY_DIR}/${KATA_ID}.tgz \
    | docker exec \
        --user root \
        --interactive \
        ${STORER_CONTAINER} \
            sh -c "tar -zxf - -C ${KATAS_ROOT}"
done

docker exec \
  --user root \
  ${STORER_CONTAINER} \
    sh -c "chown -R storer:storer ${KATAS_ROOT}/46"
