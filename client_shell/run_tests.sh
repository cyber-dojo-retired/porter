#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"
readonly test_files="${1:-test_*.sh}"

failed=0
for file in ${my_dir}/${test_files}; do
  ${file}
  if [ $? != 0 ]; then
    failed=1
  fi
done

exit ${failed}
