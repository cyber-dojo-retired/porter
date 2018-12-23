
readonly shell_dir="$( cd "$( dirname "${0}" )" && pwd )"
readonly PORT_STORER_2_SAVER=${shell_dir}/../port_cyber_dojo_storer_to_saver.sh

port()
{
  ${PORT_STORER_2_SAVER} ${*} >${stdoutF} 2>${stderrF}
  status=$?
  echo ${status} >${statusF}
}

# - - - - - - - - - - - - - - - - - - - - - - - -

get_image_name()
{
  local name=${1}
  echo "cyber-dojo-shell-${name}"
}

get_data_container_name()
{
  local name=${1}
  local image_name=$(get_image_name "${name}")
  echo "${image_name}-dc"
}

# - - - - - - - - - - - - - - - - - - - - - - - -

create_stub_storer_data_container()
{
  local name=${1}
  local image_name=$(get_image_name "${name}")
  local dc_name=$(get_data_container_name "${name}")

  cd ${shell_dir} && \
    docker build \
      --tag=${image_name} \
      --file=./Dockerfile.storer-data-container \
      . \
      > /dev/null

  docker rm --force --volumes ${dc_name} > /dev/null 2>&1 || true

  docker create \
    --name ${dc_name} \
    ${image_name} \
    > /dev/null

  export STORER_DATA_CONTAINER_NAME=${dc_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - -

on_host_cmd()
{
  local cmd="${1}"
  local dm_ssh="docker-machine ssh ${DOCKER_MACHINE_NAME}"
  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    echo "${dm_ssh} sudo ${cmd}"
  else
    echo "sudo ${cmd}"
  fi
}

on_host()
{
  local cmd=$(on_host_cmd "${1}")
  $(${cmd})
}

create_stub_saver_volume_mount_root_dir()
{
  local name=${1}
  local image_name=$(get_image_name "${name}")
  local dc_name=$(get_data_container_name "${name}")
  local cmd=$(on_host_cmd "mktemp -d /tmp/${dc_name}-saver.XXXXXX")
  export SAVER_HOST_ROOT_DIR=$(${cmd})
  on_host "mkdir ${SAVER_HOST_ROOT_DIR}/cyber-dojo"
  if [ ! "${2}" = "no-chown" ]; then
    on_host "chown -R 19663:65533 ${SAVER_HOST_ROOT_DIR}"
  fi
}

create_stub_porter_volume_mount_root_dir()
{
  local name=${1}
  local image_name=$(get_image_name "${name}")
  local dc_name=$(get_data_container_name "${name}")
  local cmd=$(on_host_cmd "mktemp -d /tmp/${dc_name}-porter.XXXXXX")
  export PORTER_HOST_ROOT_DIR=$(${cmd})
  on_host "mkdir ${PORTER_HOST_ROOT_DIR}/porter"
  if [ ! "${2}" = "no-chown" ]; then
    on_host "chown -R 19664:65533 ${PORTER_HOST_ROOT_DIR}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -

cleanup_stubs()
{
  local name=${1}
  local image_name=$(get_image_name "${name}")
  local dc_name=$(get_data_container_name "${name}")
  # TODO: call in trap?
  on_host "rm -rf ${SAVER_HOST_ROOT_DIR}"
  on_host "rm -rf ${PORTER_HOST_ROOT_DIR}"
  docker container rm --force --volumes ${dc_name} > /dev/null 2>&1
  docker image rm --force ${image_name}            > /dev/null 2>&1
}
