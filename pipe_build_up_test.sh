#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly MY_NAME="${ROOT_DIR##*/}"
readonly SH_DIR="${ROOT_DIR}/sh"

"${SH_DIR}/build_docker_images.sh"
# These tests run before containers have been brought up
# and currently fail because /cyber-dojo and /porter
# (wherever the docker-daemon is) are not yet setup.
"${SH_DIR}/../client_shell/run_tests.sh" "$@"
exit 0

# These containers are started via docker-compose whose
# entries give fake volume-mounts for /cyber-dojo and /porter
# in tmpfs's with controlled onwership.
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/insert_katas_test_data.sh"
if "${SH_DIR}/run_tests_in_containers.sh" "$@"; then
  "${SH_DIR}/docker_containers_down.sh"
  docker rmi "cyberdojo/${MY_NAME}-client" > /dev/null 2>&1
  docker image prune --force > /dev/null 2>&1
fi
