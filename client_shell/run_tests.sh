#!/bin/bash
set -e

# These tests run with fake volume-mounts hooked into the main
# port_cyber_dojo_storer_to_saver.sh script

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"
readonly glob="${1}"

for test_file in ${my_dir}/test_${glob}*; do
  ${test_file}
done
