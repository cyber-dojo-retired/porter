#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly STORER_CONTAINER=${1}
readonly KATAS_ROOT=${2}

# - - - - - - - - - - - - - - - - - - - - - - - -

echo "inserting 4D/ katas into ${STORER_CONTAINER}"
echo "...4D..."
cat ${MY_DIR}/4D.tgz \
  | docker exec \
      --user root \
      --interactive \
      ${STORER_CONTAINER} \
          sh -c "tar -zxf - -C ${KATAS_ROOT}"
