#!/bin/bash

readonly name=porter
readonly dir=porter
readonly uid=19664

if [[ ! -d /${dir} ]]; then
  echo "ERROR"
  echo "The ${name} service needs to volume-mount /${dir} on the host"
  echo "Please run"
  echo "  \$ [sudo] mkdir /${dir}"
  echo "If you are running on Docker-Toolbox"
  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    echo "(and it looks like you are)"
  fi
  echo "remember to run this on the target VM."
  echo "For example"
  echo "  \$ docker-machine ssh default sudo mkdir /${dir}"
  exit 1
fi

readonly probe="for-ownership"
mkdir /${dir}/${probe} 2>/dev/null
if [ $? -ne 0 ] ; then
  echo "ERROR"
  echo "The ${name} service (uid=${uid}) needs write access to /${dir}"
  echo "Please run:"
  echo "  $ [sudo] chown ${uid} /${dir}"
  echo "If you are running on Docker-Toolbox"
  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    echo "(and it looks like you are)"
  fi
  echo "remember to run this on the target VM."
  echo "For example"
  echo "  \$ docker-machine ssh default sudo chown ${uid} /${dir}"
  exit 2
else
  rmdir /${dir}/${probe}
fi

# - - - - - - - - - - - - - - - - - - - - -
set -e

if [ ! -d /${dir}/id-map ]; then
  mkdir /${dir}/id-map
fi

bundle exec rackup \
  --warn           \
  --host 0.0.0.0   \
  --port 4517      \
  --server thin    \
  --env production \
    config.ru
