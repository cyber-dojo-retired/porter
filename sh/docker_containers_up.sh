#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly MY_NAME=porter

# - - - - - - - - - - - - - - - - - - - -

wait_till_ready()
{
  local name="${1}"
  local port="${2}"
  local max_tries=20
  local cmd="curl --silent --fail --data '{}' -X GET http://localhost:${port}/sha"
  cmd+=" > /dev/null 2>&1"

  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    cmd="docker-machine ssh ${DOCKER_MACHINE_NAME} ${cmd}"
  fi
  echo -n "Checking ${name} is ready"
  while [ $(( max_tries -= 1 )) -ge 0 ] ; do
    echo -n '.'
    if eval ${cmd} ; then
      echo 'OK'
      return
    else
      sleep 0.1
    fi
  done
  echo 'FAIL'
  echo "${name} not ready after 20 tries"
  docker logs ${name}
  exit 1
}

# - - - - - - - - - - - - - - - - - - -

wait_till_up()
{
  local name="${1}"
  local n=20
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q ^${name}$ ; then
      return
    else
      sleep 0.1
    fi
  done
  echo "${name} not up after 20 tries"
  docker logs "${name}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - -

exit_unless_started_cleanly()
{
  local name="${1}"
  local docker_logs=$(docker logs "${name}")
  if [[ ! -z "${docker_logs}" ]]; then
    echo "[docker logs ${name}] not empty on startup"
    echo "<docker_logs>"
    echo "${docker_logs}"
    echo "</docker_logs>"
    exit 1
  fi
}

# - - - - - - - - - - - - - - - - - - - -

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_till_ready "test-${MY_NAME}-server" 4517
wait_till_ready "test-${MY_NAME}-saver"  4537

wait_till_up "test-${MY_NAME}-client"
wait_till_up "test-${MY_NAME}-storer"

exit_unless_started_cleanly "test-${MY_NAME}-server"
