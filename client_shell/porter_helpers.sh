
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

# - - - - - - - - - - - - - - - - - - - - - - - -

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

# - - - - - - - - - - - - - - - - - - - - - - - -

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

assert_porter_file_exists()
{
  local path="${PORTER_HOST_ROOT_DIR}/${1}"
  local message="expected file ${1} to exist"
  $(on_host "[ -f ${path} ]")
  local status=$?
  assertTrue "${message}" ${status}
}

# - - - - - - - - - - - - - - - - - - - - - - - -

insert_kata_data_in_storer_data_container()
{
  local name="${1}"
  local katas_name="${2}"
  local dc_name=$(get_data_container_name "${name}")
  # create storer container with data-container
  local cid=$(docker run \
    --detach \
    --interactive \
    --volumes-from ${dc_name} \
     cyberdojo/storer sh)
  # insert test data set into storer's data-container
  local cid2=$(docker run \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
      cyberdojo/inserter ${cid} ${katas_name})
  docker container rm --force ${cid} > /dev/null
}

# - - - - - - - - - - - - - - - - - - - - - - - -

create_stubs_and_insert_test_data()
{
  local name="${1}"
  local data_name="${2}"
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} ${data_name}
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

# - - - - - - - - - - - - - - - - - - - - - - - -

assert_stdout_includes_installed()
{
  local name=${1}
  assert_stdout_includes "Checking ${name} is installed. OK"
}

# - - - - - - - - - - - - - - - - - - - - - - - -

assert_stdout_includes_storers_data_container_exists()
{
  assert_stdout_includes "Checking storer's data-container exists. OK"
}

# - - - - - - - - - - - - - - - - - - - - - - - -

assert_stdout_includes_not_already_running()
{
  local name=${1}
  assert_stdout_includes "Checking the ${name} service is not already running. OK"
}

# - - - - - - - - - - - - - - - - - - - - - - - -

assert_stdout_includes_ready()
{
  local name=${1}
  local stdout="`cat ${stdoutF}`"
  local result=${2}
  local prefix="Checking the ${name} service is ready"
  local regex="${prefix}\\.+${result}"
  if [[ ! ${stdout} =~ ${regex} ]]; then
    fail "stdout did not include: ${prefix}...${result}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -

readonly network_name="port_cyber_dojo_storer_to_saver"

assert_stdout_includes_the_network_has_been_created()
{
  assert_stdout_includes "Checking the network ${network_name} has been created. OK"
}

assert_stdout_includes_removing_the_network()
{
  assert_stdout_includes "Removing the network ${network_name}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -

assert_stdout_includes_stopping()
{
  local name=${1}
  assert_stdout_includes "Stopping the ${name} service"
}

assert_stdout_includes_removing()
{
  local name=${1}
  assert_stdout_includes "Removing the ${name} service"
}

# - - - - - - - - - - - - - - - - - - - - - - - -

assert_stdout_includes_all_up_down()
{
  assert_stdout_includes_installed docker # 1
  assert_stdout_includes_installed curl # 2
  assert_stdout_includes_storers_data_container_exists # 3
  assert_stdout_includes_not_already_running storer # 4
  assert_stdout_includes_not_already_running mapper # 5
  assert_stdout_includes_not_already_running saver # 6
  assert_stdout_includes_not_already_running porter # 7
  assert_stdout_includes_the_network_has_been_created # 8
  assert_stdout_includes_ready storer OK # 9
  assert_stdout_includes_ready mapper OK # 10
  assert_stdout_includes_ready saver OK # 11
  assert_stdout_includes_ready porter OK # 12
  assert_stdout_includes_stopping storer # 13
  assert_stdout_includes_removing storer # 14
  assert_stdout_includes_stopping mapper # 15
  assert_stdout_includes_removing mapper # 16
  assert_stdout_includes_stopping saver # 17
  assert_stdout_includes_removing saver # 18
  assert_stdout_includes_stopping porter # 19
  assert_stdout_includes_removing porter # 20
  assert_stdout_includes_removing_the_network # 21
}

assert_stdout_includes_storer_empty()
{
  assert_stdout_includes "storer is empty"
}

# - - - - - - - - - - - - - - - - - - - - - - - -

assert_stdout_equals_id10()
{
  assert_stdout_line_count_equals 1
  local id10="`cat ${stdoutF}`"
  if [[ ! "${#id10}" = "10" ]]; then
    fail "${id10} is not 10-digits long"
  fi
  local id10_regex="[0-9a-zA-Z]{10}"
  if [[ ! ${id10} =~ ${id10_regex} ]]; then
    fail "${id10} is not a 10-digit id"
  fi
}

assert_stdout_equals_id2()
{
  assert_stdout_line_count_equals 1
  local id2="`cat ${stdoutF}`"
  if [[ ! "${#id2}" = "2" ]]; then
    fail "${id2} is not 2-digits long"
  fi
  local id2_regex="[0-9a-zA-Z]{2}"
  if [[ ! ${id2} =~ ${id2_regex} ]]; then
    fail "${id2} is not a 2-digit id"
  fi
}

# = = = = = = = = = = = = = = = = = = = = = = = =

assert_stderr_equals_storer_already_running()
{
  assert_stderr_includes "ERROR"
  assert_stderr_includes "A storer service is already running"
  assert_stderr_includes "Please run $ [sudo] docker rm -f storer"
  assert_stderr_line_count_equals 3
}

assert_stderr_equals_mapper_already_running()
{
  assert_stderr_includes "ERROR"
  assert_stderr_includes "A mapper service is already running"
  assert_stderr_includes "Please run $ [sudo] docker rm -f mapper"
  assert_stderr_line_count_equals 3
}

assert_stderr_equals_saver_already_running()
{
  assert_stderr_includes "ERROR"
  assert_stderr_includes "A saver service is already running"
  assert_stderr_includes "Please run $ [sudo] docker rm -f saver"
  assert_stderr_line_count_equals 3
}

assert_stderr_equals_porter_already_running()
{
  assert_stderr_includes "ERROR"
  assert_stderr_includes "A porter service is already running"
  assert_stderr_includes "Please run $ [sudo] docker rm -f porter"
  assert_stderr_line_count_equals 3
}

assert_stderr_equals_cant_find_storers_data_container()
{
  assert_stderr_includes "ERROR"
  assert_stderr_includes "Cannot find storer's data-container cyber-dojo-katas-DATA-CONTAINER"
  assert_stderr_line_count_equals 2
}

assert_stderr_equals_no_rights_to_saver_volume_mount()
{
  assert_stderr_includes "ERROR"
  assert_stderr_includes "The saver service needs write access to /cyber-dojo"
  assert_stderr_includes "username=saver (uid=19663)"
  assert_stderr_includes "group=nogroup (gid=65533)"
  assert_stderr_includes "Please run:"
  assert_stderr_includes "  \$ [sudo] chown 19663:65533 /cyber-dojo"
  assert_stderr_includes "If you are running on Docker-Toolbox remember"
  assert_stderr_includes "to run this on the target VM. For example:"
  assert_stderr_includes "  \$ docker-machine ssh default sudo chown 19663:65533 /cyber-dojo"
  assert_stderr_line_count_equals 9
}

assert_stderr_equals_no_rights_to_porter_volume_mount()
{
  assert_stderr_includes "ERROR"
  assert_stderr_includes "The porter service needs write access to /porter"
  assert_stderr_includes "username=porter (uid=19664)"
  assert_stderr_includes "group=nogroup (gid=65533)"
  assert_stderr_includes "Please run:"
  assert_stderr_includes "  \$ [sudo] chown 19664:65533 /porter"
  assert_stderr_includes "If you are running on Docker-Toolbox remember"
  assert_stderr_includes "to run this on the target VM. For example:"
  assert_stderr_includes "  \$ docker-machine ssh default sudo chown 19664:65533 /porter"
  assert_stderr_line_count_equals 9
}
