#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly STORER_CONTAINER=${1}
readonly KATAS_ROOT=${2}

echo -n '.'
cat ${MY_DIR}/89.tgz \
  | docker exec \
      --user root \
      --interactive \
      ${STORER_CONTAINER} \
          sh -c "tar -zxf - -C ${KATAS_ROOT}"

# notes.txt file
docker exec \
  --user root \
  ${STORER_CONTAINER} \
    sh -c "chown -R storer ${KATAS_ROOT}/89"

docker exec \
  --user root \
  ${STORER_CONTAINER} \
    sh -c "chown -R nobody ${KATAS_ROOT}/89/0C8AE514/elephant/sandbox"

docker exec \
  --user root \
  ${STORER_CONTAINER} \
    sh -c "chown -R nobody ${KATAS_ROOT}/89/716C1BC6/swan/sandbox"
