#!/bin/bash
set -ev

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  docker pull cyberdojo/storer
  docker pull cyberdojo/saver
  ./pipe_build_up_test.sh
  echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
  docker push cyberdojo/porter
fi
