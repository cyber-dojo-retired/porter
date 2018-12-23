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
    echo "  \$ ${my_name} --id10"
    echo "Then try porting it."
    echo "For example, if the 10-digit id is 9f8TeZMZA2"
    echo "  \$ ${my_name} 9f8TeZMZA2"
    echo
    echo "If all is well, you can move on to porting all"
    echo "the sessions with a given 2-digit prefix."
    echo "To show a randomly sampled 2-digit id:"
    echo "  \$ ${my_name} --id2"
    echo "Then try porting them."
    echo "For example, if the 2-digit prefix is 5A"
    echo "  \$ ${my_name} 5A"
    echo
    echo "If all is well, port all the sessions:"
    echo "  \$ ${my_name} --all"
    echo ""
    exit 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare storer_cid=""
readonly storer_port=4577

declare saver_cid=""
readonly saver_port=4537

declare porter_cid=""
readonly porter_port=4517

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

readonly newline=$'\n'

declare show_log="true"

if [ "${1}" = "--nolog" ]; then
  shift
  show_log="false"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

log()
{
  if [ "${show_log}" = "true" ]; then
    echo "${1}" "${2}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

remove_docker_network()
{
  log "Removing network ${network_name}"
  docker network rm ${network_name} > /dev/null
}
remove_one_service()
{
  local name=${1}
  local cid=${2}
  if [ ! -z "${cid}" ]; then
    log "Stopping service ${name}"
    docker container stop --time 1 ${cid} > /dev/null
    log "Removing service ${name}"
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
  log "Confirmed: network ${network_name} has been created"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

error()
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
  if ! hash ${cmd} 2> /dev/null ; then
    error 1 "ERROR: ${cmd} needs to be installed"
  else
    log "Confirmed: ${cmd} is installed"
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

exit_unless_storer_preconditions_met()
{
  if exists_container storer ; then
    message+="ERROR: A storer service already exists${newline}"
    message+="Please run $ [sudo] cyber-dojo down${newline}"
    error 2 "${message}"
  else
    log 'Confirmed: the storer service is not already running'
  fi
  if ! docker ps --all | grep ${storer_data_container_name} > /dev/null ; then
    error 3 "ERROR: Cannot find storer's data-container ${storer_data_container_name}"
  else
    log 'Confirmed: found the storer data-container'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_saver_preconditions_met()
{
  if exists_container saver ; then
    message+="ERROR: A saver service already exists${newline}"
    message+="Please run $ [sudo] cyber-dojo down${newline}"
    error 4 "${message}"
  else
    log 'Confirmed: the saver service is not already running'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_porter_preconditions_met()
{
  if exists_container porter ; then
    message+="ERROR: A porter service already exists${newline}"
    message+="Please run $ [sudo] docker rm -f porter${newline}"
    error 5 "${message}"
  else
    log 'Confirmed: the porter service is not already running'
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
  while [ $(( max_tries -= 1 )) -ge 0 ] ; do
    log -n '.'
    if eval ${cmd} ; then
      echo
      log "Confirmed: the ${name} service is running"
      return 0 # true
    else
      sleep 0.05
    fi
  done
  echo
  local docker_log="$(docker logs ${cid})"
  error ${error_code} "${docker_log}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_storer_service()
{
  log "Starting the storer service"
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
  log "Starting the saver service"
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
  log "Starting the porter service"
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

exit_unless_installed docker
exit_unless_installed curl

exit_unless_storer_preconditions_met
exit_unless_saver_preconditions_met
exit_unless_porter_preconditions_met

create_docker_network
trap remove_all_services_and_network EXIT INT

#TODO: restore this
#pull_latest_images
run_storer_service
run_saver_service
run_porter_service

run_port_exec ${*}
