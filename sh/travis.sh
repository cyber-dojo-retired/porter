#!/bin/bash
set -ev

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  docker pull cyberdojo/storer
  docker pull cyberdojo/saver
  ./pipe_build_up_test.sh
  echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
  docker push cyberdojo/porter
  docker push cyberdojo/inserter  
  #curl -O https://raw.githubusercontent.com/cyber-dojo/cyber-dojo/master/shared/push_and_trigger.sh
  #chmod +x push_and_trigger.sh
  #./push_and_trigger.sh cyber-dojo/web
fi
