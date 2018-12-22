#!/bin/bash
set -e

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"
readonly test_files="${1:-test_*.sh}"

for test_file in ${my_dir}/${test_files}; do
  ${test_file}
done
