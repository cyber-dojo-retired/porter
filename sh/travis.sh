#!/bin/bash
set -ev

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  pwd
  ./pipe_build_up_test.sh
  curl -O https://raw.githubusercontent.com/cyber-dojo/cyber-dojo/master/shared/push_and_trigger.sh
  chmod +x push_and_trigger.sh
  ./push_and_trigger.sh cyber-dojo/web
fi
