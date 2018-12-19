#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

failed=0
for file in ${MY_DIR}/test_*.sh; do
  ${file}
  if [ $? != 0 ]; then
    failed=1
  fi
done

exit ${failed}
