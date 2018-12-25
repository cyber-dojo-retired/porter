#!/bin/bash

readonly name=porter # name of the service
readonly dir=porter
readonly uid=19664
readonly username=porter
readonly gid=65533
readonly group=nogroup
readonly vm_target=${DOCKER_MACHINE_NAME:-default}

if [[ ! -d /${dir} ]]; then
  cmd="mkdir /${dir}"
  echo "ERROR"
  echo "The ${name} service needs to volume-mount /${dir}"
  echo "Please run:"
  echo "  \$ [sudo] ${cmd}"
  echo "If you are running on Docker-Toolbox remember"
  echo "to run this on the target VM. For example:"
  echo "  \$ docker-machine ssh ${vm_target} sudo ${cmd}"
  exit 1
fi

readonly probe="for-ownership"
mkdir /${dir}/${probe} 2>/dev/null
if [ $? -ne 0 ] ; then
  cmd="chown ${uid}:${gid} /${dir}"
  echo "ERROR"
  echo "The ${name} service needs write access to /${dir}"
  echo "username=${username} (uid=${uid})"
  echo "group=${group} (gid=${gid})"
  echo "Please run:"
  echo "  $ [sudo] ${cmd}"
  echo "If you are running on Docker-Toolbox remember"
  echo "to run this on the target VM. For example:"
  echo "  \$ docker-machine ssh ${vm_target} sudo ${cmd}"
  exit 2
else
  rmdir /${dir}/${probe}
fi

# - - - - - - - - - - - - - - - - - - - - -
set -e

if [ ! -d /${dir}/id-map ]; then
  mkdir /${dir}/id-map
fi

rackup             \
  --env production \
  --host 0.0.0.0   \
  --port 4517      \
  --server thin    \
  --warn           \
    config.ru
