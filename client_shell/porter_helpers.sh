
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

readonly PORT_STORER_2_SAVER=${MY_DIR}/../port_cyber_dojo_storer_to_saver.sh
readonly dm_ssh="docker-machine ssh ${DOCKER_MACHINE_NAME}"

port()
{
  ${PORT_STORER_2_SAVER} ${*} >${stdoutF} 2>${stderrF}
  status=$?
  echo ${status} >${statusF}
}

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

create_stub_storer_data_container()
{
  local name=${1}
  local image_name=$(get_image_name "${name}")
  local dc_name=$(get_data_container_name "${name}")

  cd ${MY_DIR} && \
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

create_root_dir_for_saver_volume_mount()
{
  local name=${1}
  local image_name=$(get_image_name "${name}")
  local dc_name=$(get_data_container_name "${name}")
  export SAVER_HOST_ROOT_DIR=$(${dm_ssh} sudo mktemp -d /tmp/${dc_name}-saver.XXXXXX)
  $(${dm_ssh} sudo mkdir ${SAVER_HOST_ROOT_DIR}/cyber-dojo)
  $(${dm_ssh} sudo chown -R 19663:65533 ${SAVER_HOST_ROOT_DIR})
}

create_root_dir_for_porter_volume_mount()
{
  local name=${1}
  local image_name=$(get_image_name "${name}")
  local dc_name=$(get_data_container_name "${name}")
  export PORTER_HOST_ROOT_DIR=$(${dm_ssh} sudo mktemp -d /tmp/${dc_name}-porter.XXXXXX)
  $(${dm_ssh} sudo mkdir ${PORTER_HOST_ROOT_DIR}/porter)
  $(${dm_ssh} sudo chown -R 19664:65533 ${PORTER_HOST_ROOT_DIR})
}

cleanup()
{
  local name=${1}
  local image_name=$(get_image_name "${name}")
  local dc_name=$(get_data_container_name "${name}")
  # TODO: call in trap
  $(${dm_ssh} sudo rm -rf ${SAVER_HOST_ROOT_DIR})  > /dev/null 2>&1 || true
  $(${dm_ssh} sudo rm -rf ${PORTER_HOST_ROOT_DIR}) > /dev/null 2>&1 || true
  docker container rm --force --volumes ${dc_name} > /dev/null 2>&1 || true
  docker image rm --force ${image_name}            > /dev/null 2>&1 || true
}
