#!/bin/bash
set -e

show_help()
{
  local my_name=`basename "${0}"`
  if [ "${1}" = "--help" ] || [ "${1}" = "" ]; then
    echo
    echo "Ports cyber-dojo practice sessions from their old format to their new format."
    echo "The old format used:"
    echo "  o) 10-digit ids"
    echo "  o) a service called storer"
    echo "  o) a docker data-container."
    echo "The new format uses:"
    echo "  o) 6-digit ids (with a larger alphabet)"
    echo "  o) a service called saver"
    echo "  o) a volume-mount"
    echo
    echo "Porting is destructive. As each session is successfully"
    echo "ported to saver it is removed from storer."
    echo
    echo "As each session is ported, a single P/E/M character is printed:"
    echo
    echo "   P - The session ported ok."
    echo "       This means the new 6-digit id is the 1st 6 chars of the 10-digit id."
    echo "       For example 9f8TeZMZA2 --> 9f8TeZ"
    echo
    echo "   M - The session ported ok but needed an id-map."
    echo "       This means the new 6-digit id is NOT the 1st 6 chars of the 10-digit id."
    echo "       For example 9f8TeZMZA2 -> uQMecK"
    echo "       ...EXPLAIN WHERE THIS MAPPING INFO IS HELD..."
    echo
    echo "   E - The session failed to port."
    echo "       An exception arose. The session is still in the storer."
    echo "       ...EXPLAIN WHERE THIS EXCEPTION INFO IS HELD..."
    echo
    echo "First try porting a few single sessions."
    echo "To show a randomly selected 10-digit id:"
    echo "  \$ ${my_name} --show10"
    echo "Then try porting it."
    echo "For example, if the 10-digit id is 9f8TeZMZA2"
    echo "  \$ ${my_name} 9f8TeZMZA2"
    echo
    echo "If all is well, you can move on to porting all"
    echo "the sessions with a given 2-digit prefix."
    echo "To show a randomly selected 2-digit id:"
    echo "  \$ ${my_name} --show2"
    echo "Then try porting them."
    echo "For example, if the 2-digit prefix is 5A"
    echo "  \$ ${my_name} 5A"
    echo
    echo "If all is well, you can move on to porting storer to saver completely:"
    echo "  \$ ${my_name} --all"
    echo ""
    exit 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare network_name=""

declare storer_cid=""
declare saver_cid=""
declare porter_cid=""

readonly storer_port=4577
readonly saver_port=4537
readonly porter_port=4517

declare verbose=1
if [ "${1}" = "--verbose" ]; then
  shift
  verbose=0
  set -x
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info()
{
  local msg="${1}"
  if [ "${verbose}" = "0" ]; then
    echo "${msg}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

remove_docker_network()
{
  if [ ! -z ${network_name} ]; then
    info "Removing network ${network_name}"
    docker network rm ${network_name} > /dev/null
  fi
}
remove_one_service()
{
  local name=${1}
  local cid=${2}
  if [ ! -z "${cid}" ]; then
    info "Stopping service ${name}"
    docker container stop --time 1 ${cid} > /dev/null
    info "Removing service ${name}"
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
trap remove_all_services_and_network EXIT INT

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
    error 1 "ERROR: ${cmd} needs to be installed!"
  else
    info "Confirmed: ${cmd} is installed."
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

create_docker_network()
{
  local name=port_cyber_dojo_storer_to_saver
  docker network create --driver bridge ${name} > /dev/null
  network_name=${name}
  info "Confirmed: network ${network_name} has been created."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

running_container()
{
  local space='\s'
  local name=$1
  local end_of_line='$'
  docker ps --filter "name=${name}" | grep "${space}${name}${end_of_line}" > /dev/null
  return $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_storer_preconditions_met()
{
  if running_container storer ; then
    message+="ERROR: The storer service is already running!${newline}"
    message+="Please run $ [sudo] cyber-dojo down${newline}"
    error 2 ${message}
  else
    info 'Confirmed: the storer service is not already running.'
  fi
  # TODO: 3. check data-container exists?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_saver_preconditions_met()
{
  if running_container saver ; then
    message+="ERROR: The saver service is already running!${newline}"
    message+="Please run $ [sudo] cyber-dojo down${newline}"
    error 4 ${message}
  else
    info 'Confirmed: the saver service is not already running'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_porter_preconditions_met()
{
  if running_container porter ; then
    message+="ERROR: The porter service is already running!${newline}"
    message+="Please run $ [sudo] docker rm -f porter${newline}"
    error 5 ${message}
  else
    info 'Confirmed: the porter service is not already running'
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

  local cmd="curl --silent --fail -d '{}' -X GET http://localhost:${port}/sha"
  cmd+=" > /dev/null 2>&1"

  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    cmd="docker-machine ssh default ${cmd}"
  fi
  while [ $(( max_tries -= 1 )) -ge 0 ] ; do
    echo -n '.'
    if eval ${cmd} ; then
      echo
      info "Confirmed: the ${name} service is running."
      return 0 # true
    else
      sleep 0.1
    fi
  done
  echo
  local log="$(docker logs ${cid})"
  error ${error_code} "${log}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_storer_service()
{
  echo -n "Starting the storer service"
  storer_cid=$(docker run \
    --detach \
    --interactive \
    --name storer \
    --network ${network_name} \
    --publish ${storer_port}:${storer_port} \
    --tty \
      cyberdojo/storer)
  # TODO: with data-container mounted
  wait_till_running storer ${storer_port} ${storer_cid} 6
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_saver_service()
{
  echo -n "Starting the saver service"
  saver_cid=$(docker run \
    --detach \
    --env DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME} \
    --interactive \
    --name saver \
    --network ${network_name} \
    --publish ${saver_port}:${saver_port} \
    --tty \
    --volume /cyber-dojo:/cyber-dojo \
      cyberdojo/saver)

  wait_till_running saver ${saver_port} ${saver_cid} 7
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_porter_service()
{
  echo -n "Starting the porter service"
  porter_cid=$(docker run \
    --detach \
    --env DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME} \
    --interactive \
    --name porter \
    --network ${network_name} \
    --publish ${porter_port}:${porter_port} \
    --tty \
    --volume /porter:/porter \
      cyberdojo/porter)

  wait_till_running porter ${porter_port} ${porter_cid} 8
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_port_exec()
{
  # Note: web will use porter's rack-dispatcher API, we don't
  docker exec -it \
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
#TODO: restore this
#pull_latest_images
run_storer_service
run_saver_service
run_porter_service

run_port_exec ${*}
