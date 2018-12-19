#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly SCRIPT=${ROOT_DIR}/port_cyber_dojo_storer_to_saver.sh

echo "Work in progress here..."

# For each test...
# insert appropriate data into storer using insert_katas_test_data.sh
${SCRIPT} id42
# call port_cyber_dojo_storer_to_saver.sh ID
# verify state of saver.   via API curl? via docker exec? (docker-machine ssh default)
# verify state of storer.
# verify stdout/stderr/status
