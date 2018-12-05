#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly MY_NAME="${ROOT_DIR##*/}"

# - - - - - - - - - - - - - - - - - - - -

wait_till_up()
{
  local n=10
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q ^${1}$ ; then
      return
    else
      sleep 0.5
    fi
  done
  echo "${1} not up after 5 seconds"
  docker logs "${1}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - -

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_till_up "test-${MY_NAME}-server"
wait_till_up "test-${MY_NAME}-client"
wait_till_up "test-${MY_NAME}-storer"
wait_till_up "test-${MY_NAME}-saver"

# - - - - - - - - - - - - - - - - - - - -
# storer holds state as a volume which has already set ownership

docker exec \
  --user root \
    "test-${MY_NAME}-storer" \
      sh -c 'cd /usr/src/cyber-dojo/katas && rm -rf *'

# saver holds state as a host dir, so needs to set ownership

docker exec \
  --user root \
    "test-${MY_NAME}-saver" \
      sh -c 'cd /groups && rm -rf * && chown -R 19663:19663 /groups'

docker exec \
  --user root \
    "test-${MY_NAME}-saver" \
      sh -c 'cd /katas && rm -rf * && chown -R 19663:19663 /katas'

# porter holds state as a host dir, so needs to set ownership

docker exec \
  --user root \
    "test-${MY_NAME}-server" \
      sh -c 'cd /id-map && rm -rf * && chown -R 19664:19664 /id-map'
