#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly DATA_DIR=${1}
readonly STORER_CONTAINER=${2}
readonly KATAS_ROOT=${3}

echo "${DATA_DIR}"
for TGZ_FILE in ${MY_DIR}/../${DATA_DIR}/*.tgz
do
  echo "...$(basename "${TGZ_FILE}")"
  cat ${TGZ_FILE} \
    | docker exec \
        --user root \
        --interactive \
        ${STORER_CONTAINER} \
            sh -c "tar -zxf - -C ${KATAS_ROOT}"
done
