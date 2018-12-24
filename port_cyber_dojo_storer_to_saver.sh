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
    echo "Ports cyber-dojo practice sessions from their old format to their new format."
    echo "The old format used:"
    echo "  o) 10-digit ids"
    echo "  o) a service called storer"
    echo "  o) a docker data-container"
    echo "  o) was coupled to avatar names"
    echo "  o) fudged support for individual sessions"
    echo "The new format uses:"
    echo "  o) 6-digit ids (with a larger alphabet)"
    echo "  o) a service called saver"
    echo "  o) a volume-mounted directory"
    echo "  o) is decoupled from avatar names"
    echo "  o) properly supports individual sessions"
    echo
    echo "As each session is ported, a single P/E/M character is printed:"
    echo
    echo "  P - The session has been removed from storer and"
    echo "      the new 6-digit id is the 1st 6 chars of the old 10-digit id."
    echo "      For example 9f8TeZMZA2 --> 9f8TeZ"
    echo
    echo "  M - The session has been removed from storer and"
    echo "      the new 6-digit id is NOT the 1st 6 chars of the old 10-digit id."
    echo "      For example 9f8TeZMZA2 -> uQMecK"
    echo "      ...EXPLAIN WHERE THIS MAPPING INFO IS HELD..."
    echo
    echo "  E - The session failed to port because an exception arose"
    echo "      The session is still in the storer."
    echo "      ...EXPLAIN WHERE THIS EXCEPTION INFO IS HELD..."
    echo
    echo "First try porting a few single sessions."
    echo "To show a randomly sampled 10-digit id:"
    echo "  \$ ./${my_name} --id10"
    echo "  9f8TeZMZA2"
    echo "Then try porting it."
    echo "  \$ ./${my_name} --id10 9f8TeZMZA2"
    echo "  P"
    echo
    echo "If all is well, you can move on to porting all"
    echo "sessions with a given 2-digit prefix."
    echo "To show a randomly sampled 2-digit id:"
    echo "  \$ ./${my_name} --id2"
    echo "  5A"
    echo "Then try porting them."
    echo "  \$ ./${my_name} --id2 5A"
    echo "  5A:PPPPPPPPP..."
    echo
    echo "If all is well, port all the sessions:"
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

exit_if_storer_already_running()
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

exit_if_saver_already_running()
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

exit_if_porter_already_running()
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

pull_latest_images()
{
  docker pull cyberdojo/storer
  docker pull cyberdojo/saver
  docker pull cyberdojo/porter
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

wait_till_running()
{
  local name=${1}
  local port=${2}
  local cid=${3}
  local error_code=${4}
  local max_tries=10

  local cmd="curl --silent --fail --data '{}' -X GET http://localhost:${port}/sha"
  cmd+=" > /dev/null 2>&1"

  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    cmd="docker-machine ssh ${DOCKER_MACHINE_NAME} ${cmd}"
  fi
  info -n "Checking the ${name} service is running"
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

run_storer_service()
{
  storer_cid=$(docker run \
    --detach \
    --name storer \
    --network ${network_name} \
    --publish ${storer_port}:${storer_port} \
    --volumes-from ${storer_data_container_name} \
      cyberdojo/storer)

  wait_till_running storer ${storer_port} ${storer_cid} 6
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_saver_service()
{
  saver_cid=$(docker run \
    --detach \
    --env DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME} \
    --name saver \
    --network ${network_name} \
    --publish ${saver_port}:${saver_port} \
    --volume ${saver_host_root_dir}/cyber-dojo:/cyber-dojo \
      cyberdojo/saver)

  wait_till_running saver ${saver_port} ${saver_cid} 7
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_porter_service()
{
  porter_cid=$(docker run \
    --detach \
    --env DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME} \
    --interactive \
    --name porter \
    --network ${network_name} \
    --publish ${porter_port}:${porter_port} \
    --volume ${porter_host_root_dir}/porter:/porter \
      cyberdojo/porter)

  wait_till_running porter ${porter_port} ${porter_cid} 8
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_port_exec()
{
  # Note: web will use porter's rack-dispatcher API, we don't
  docker exec     \
    --interactive \
    --user porter \
    ${porter_cid} \
      sh -c "ruby /app/src/port.rb ${*}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_help ${*}

exit_unless_installed docker 1
exit_unless_installed curl 2
exit_unless_storer_data_container_exists 3
exit_if_storer_already_running 4
exit_if_saver_already_running 5
exit_if_porter_already_running 6

create_docker_network
trap remove_all_services_and_network EXIT INT

#TODO: restore this
#pull_latest_images
run_storer_service
run_saver_service
run_porter_service

run_port_exec ${*}
