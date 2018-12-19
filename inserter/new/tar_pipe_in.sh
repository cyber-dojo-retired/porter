#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly STORER_CONTAINER=${1}
readonly KATAS_ROOT=${2}
readonly KATA_IDS=( \
  9f8TeZMZAq \
  9f67Q9PyZm \
  9fcW44ltyz \
  9fDYJR3BfG \
  9fH6TumFV2 \
  9fSqUqMecK \
  9fT2wMW0BM \
  9fUSFm6hmT \
  9fvMuUlKbh )

# - - - - - - - - - - - - - - - - - - - - - - - -

echo "inserting new katas into ${STORER_CONTAINER}"
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
