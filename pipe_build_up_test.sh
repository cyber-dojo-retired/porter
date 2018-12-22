#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && cd sh && pwd )"

"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/insert_katas_test_data.sh"
"${SH_DIR}/run_tests_in_containers.sh" "$@"
"${SH_DIR}/docker_containers_down.sh"

#"${SH_DIR}/../client_shell/run_tests.sh" "$@"
