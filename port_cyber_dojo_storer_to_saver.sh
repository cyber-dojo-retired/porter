#!/bin/bash
set -e

# ensure porter service can see storer/saver services
readonly network_name="port_cyber_dojo_storer_to_saver"
# allow tests to specify where saver will save to
readonly saver_host_root_dir="${SAVER_HOST_ROOT_DIR:-/}"
# allow tests to specify where porter will save to
readonly porter_host_root_dir="${PORTER_HOST_ROOT_DIR:-/}"
# allow tests to specify storer's data-container
readonly storer_data_container_name="${STORER_DATA_CONTAINER_NAME:-cyber-dojo-katas-DATA-CONTAINER}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_help()
{
  local my_name=`basename "${0}"`
  if [ "${1}" = "--help" ] || [ "${1}" = "" ]; then
    echo
    echo "Ports cyber-dojo practice sessions:"
    echo "                           old-format   --->  new-format"
    echo "  o) id-length             10                 6"
    echo "  o) service name          storer             saver"
    echo "  o) storage               data-container     volume-mount"
    echo "  o) avatar-coupling?      yes                no"
    echo "  o) individual sessions?  no                 yes"
    echo
    echo "As each session is ported, a single P/E/M character is printed:"
    echo
    echo "  P - The session has been removed from storer and"
    echo "      the new 6-digit id is the 1st 6 chars of the old 10-digit id."
    echo "      For example 9f8TeZMZA2 --> 9f8TeZ"
    echo
    echo "  M - The session has been removed from storer and"
    echo "      the new 6-digit id is NOT the 1st 6 chars of the old 10-digit id."
    echo "      For example if 9f8TeZMZA2 -> uQMecK"
    echo "      then /porter/mapped-ids/9f8TeZMZA2 will contain uQMecK"
    echo
    echo "  E - The session failed to port because an exception arose"
    echo "      The session is still in the storer."
    echo "      For example if 9f8TeZMZA2 raises an exception"
    echo "      then /porter/raised-ids/9f8TeZMZA2 will contain the trace"
    echo
    echo "Please be patient - initialization takes a few seconds."
    echo "Please follow instructions - one-time chown commands will be needed."
    echo
    echo "Step 1: Pull the latest docker images for the required services:"
    echo "  \$ docker pull cyberdojo/storer"
    echo "  \$ docker pull cyberdojo/saver"
    echo "  \$ docker pull cyberdojo/porter"
    echo
    echo "Step 2: Check porting a single session works."
    echo "To show a randomly sampled 10-digit id:"
    echo "  \$ ./${my_name} --id10"
    echo "  9f8TeZMZA2"
    echo "Then port it:"
    echo "  \$ ./${my_name} --id10 9f8TeZMZA2"
    echo "  P"
    echo
    echo "Step 3: Check porting a batch of sessions works."
    echo "To show a randomly sampled 2-digit id prefix:"
    echo "  \$ ./${my_name} --id2"
    echo "  5A"
    echo "Then port them:"
    echo "  \$ ./${my_name} --id2 5A"
    echo "  5A:PPPPPPPPPPPPPP...PPP"
    echo
    echo "Step 4: Port all the sessions:"
    echo "  \$ ./${my_name} --all"
    echo ""
    exit 0
  fi
}

readonly newline=$'\n'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare storer_cid=""
readonly storer_port=4577

declare saver_cid=""
readonly saver_port=4537

declare porter_cid=""
readonly porter_port=4517

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info()
{
  if [ "${SHOW_PORTER_INFO}" = "true" ]; then
    echo "${1}" "${2}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

remove_docker_network()
{
  info "Removing the network ${network_name}"
  docker network rm ${network_name} > /dev/null
}

remove_one_service()
{
  local name=${1}
  local cid=${2}
  if [ ! -z "${cid}" ]; then
    info "Stopping the ${name} service"
    docker container stop --time 1 ${cid} > /dev/null
    info "Removing the ${name} service"
    # Very important this does NOT include --volumes
    docker container rm --force ${cid}    > /dev/null
  fi
}

remove_all_services_and_network()
{
  remove_one_service storer ${storer_cid}
  remove_one_service saver  ${saver_cid}
  remove_one_service porter ${porter_cid}
  remove_docker_network
}

create_docker_network()
{
  docker network create --driver bridge ${network_name} > /dev/null
  info "Checking the network ${network_name} has been created. OK"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

error()
{
  local status=${1}
  local msg="${2}"
  >&2 echo "ERROR"
  >&2 echo "${msg}"
  exit ${status}
}

error_no_prefix()
{
  local status=${1}
  local msg="${2}"
  >&2 echo "${msg}"
  exit ${status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_installed()
{
  local cmd=${1}
  local status=${2}
  if ! hash ${cmd} 2> /dev/null ; then
    error ${status} "${cmd} needs to be installed"
  else
    info "Checking ${cmd} is installed. OK"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exists_container()
{
  local name=${1}
  if docker ps --all --format '{{.Names}}' | grep "${name}" > /dev/null ; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_storer_data_container_exists()
{
  local status=${1}
  if ! docker ps --all | grep ${storer_data_container_name} > /dev/null ; then
    error ${status} "Cannot find storer's data-container ${storer_data_container_name}"
  else
    info "Checking storer's data-container exists. OK"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_if_already_running_storer()
{
  local status=${1}
  if exists_container storer ; then
    message+="A storer service is already running${newline}"
    message+="Please run $ [sudo] cyber-dojo down"
    error ${status} "${message}"
  else
    info 'Checking the storer service is not already running. OK'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_if_already_running_saver()
{
  local status=${1}
  if exists_container saver ; then
    message+="A saver service is already running${newline}"
    message+="Please run $ [sudo] cyber-dojo down"
    error ${status} "${message}"
  else
    info 'Checking the saver service is not already running. OK'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_if_already_running_porter()
{
  local status=${1}
  if exists_container porter ; then
    message+="A porter service is already running${newline}"
    message+="Please run $ [sudo] docker rm -f porter"
    error ${status} "${message}"
  else
    info 'Checking the porter service is not already running. OK'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

wait_till_ready()
{
  local name="${1}"
  local error_code="${2}"
  local method="${3}"
  local max_tries=40
  local vport="${name}_port"
  local port="${!vport}"
  local vcid="${name}_cid"
  local cid="${!vcid}"

  local cmd="curl --silent --fail --data '{}' -X GET http://localhost:${port}/${method}"
  cmd+=" > /dev/null 2>&1"

  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    cmd="docker-machine ssh ${DOCKER_MACHINE_NAME} ${cmd}"
  fi
  info -n "Checking the ${name} service is ready"
  while [ $(( max_tries -= 1 )) -ge 0 ] ; do
    info -n '.'
    if eval ${cmd} ; then
      info 'OK'
      return 0 # true
    else
      sleep 0.05
    fi
  done
  info 'FAIL'
  local docker_log="$(docker logs ${cid})"
  error_no_prefix ${error_code} "${docker_log}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_service_storer()
{
  storer_cid=$(docker run \
    --detach \
    --name storer \
    --network ${network_name} \
    --publish ${storer_port}:${storer_port} \
    --user storer \
    --volumes-from ${storer_data_container_name} \
      cyberdojo/storer)
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_service_saver()
{
  saver_cid=$(docker run \
    --detach \
    --env DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME} \
    --name saver \
    --network ${network_name} \
    --publish ${saver_port}:${saver_port} \
    --user saver \
    --volume ${saver_host_root_dir}/cyber-dojo:/cyber-dojo \
      cyberdojo/saver)
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_service_porter()
{
  porter_cid=$(docker run \
    --detach \
    --env DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME} \
    --name porter \
    --network ${network_name} \
    --publish ${porter_port}:${porter_port} \
    --user porter \
    --volume ${porter_host_root_dir}/porter:/porter \
      cyberdojo/porter)
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_port_exec()
{
  # Note: web will use porter's rack-dispatcher API, we don't
  docker exec     \
    --user porter \
    ${porter_cid} \
      sh -c "ruby /app/src/port.rb ${*}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_help ${*}

exit_unless_installed docker 1
exit_unless_installed curl 2

exit_unless_storer_data_container_exists 3

exit_if_already_running_storer 4
exit_if_already_running_saver  5
exit_if_already_running_porter 6

create_docker_network
trap remove_all_services_and_network EXIT INT

run_service_storer
run_service_saver
run_service_porter

wait_till_ready storer 7 sha
wait_till_ready saver  8 sha
wait_till_ready porter 9 ready

run_port_exec ${*}
