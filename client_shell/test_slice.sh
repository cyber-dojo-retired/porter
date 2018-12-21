#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"
readonly sh_dir="${my_dir}/sh"

. ${my_dir}/porter_helpers.sh

readonly dmc="docker-machine ssh ${DOCKER_MACHINE_NAME}"

test_415_slice()
{
  local name=${FUNCNAME[0]}
  local image_name="cyber-dojo-porter-client-shell-${name}"
  local dc_name="${image_name}-dc"

  # create image +data-container
  ${sh_dir}/docker_build_volumed_image.sh ${image_name}
  docker rm --force --volumes ${dc_name} || true
  ${sh_dir}/docker_create_data_container.sh ${image_name} ${dc_name}
  export STORER_DATA_CONTAINER_NAME=${dc_name}

  # create root dir for saver volume-mount
  export SAVER_HOST_ROOT_DIR=$(${dmc} sudo mktemp -d /tmp/${dc_name}-saver.XXXXXX)
  $(${dmc} sudo mkdir ${SAVER_HOST_ROOT_DIR}/cyber-dojo)
  $(${dmc} sudo chown -R 19663:65533 ${SAVER_HOST_ROOT_DIR})

  # create root dir for porter volume-mount
  export PORTER_HOST_ROOT_DIR=$(${dmc} sudo mktemp -d /tmp/${dc_name}-porter.XXXXXX)
  $(${dmc} sudo mkdir ${PORTER_HOST_ROOT_DIR}/porter)
  $(${dmc} sudo chown -R 19664:65533 ${PORTER_HOST_ROOT_DIR})

  port id42
  assertStdoutIncludes 'Hello from port.rb id42'
  assertStdoutIncludes 'porter.sha=='
  assertStdoutIncludes 'storer.sha=='
  assertStdoutIncludes 'saver.sha=='
  assertStderrEquals ''
  assertStatusEquals 0

  $(${dmc} sudo rm -rf ${SAVER_HOST_ROOT_DIR})
  $(${dmc} sudo rm -rf ${PORTER_HOST_ROOT_DIR})
  docker container rm --force --volume ${dc_name}
  docker image rm --force ${image_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
