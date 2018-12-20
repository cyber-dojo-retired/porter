#!/bin/bash

readonly name=porter # of the service
readonly dir=porter
readonly uid=19664
readonly user_name=porter
readonly gid=65534
readonly group_name=nogroup

if [[ ! -d /${dir} ]]; then
  cmd="mkdir /${dir}"
  echo "ERROR"
  echo "The ${name} service needs to volume-mount /${dir} on the host"
  echo "Please run:"
  echo "  \$ [sudo] ${cmd}"
  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    echo "If you are running on Docker-Toolbox (and it looks like you are)"
    echo "remember to run this on the target VM. For example:"
    echo "  \$ docker-machine ssh ${DOCKER_MACHINE_NAME} sudo ${cmd}"
  fi
  exit 1
fi

readonly probe="for-ownership"
mkdir /${dir}/${probe} 2>/dev/null
if [ $? -ne 0 ] ; then
  cmd="chown ${uid}:${gid} /${dir}"
  echo "ERROR"
  echo "The ${name} service needs write access to /${dir}"
  echo "uid=${uid} (username=${user_name})"
  echo "gid=${gid} (group=${group_name})"
  echo "Please run:"
  echo "  $ [sudo] chown ${cmd}"
  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    echo "If you are running on Docker-Toolbox (and it looks like you are)"
    echo "remember to run this on the target VM. For example:"
    echo "  \$ docker-machine ssh ${DOCKER_MACHINE_NAME} sudo ${cmd}"
  fi
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
