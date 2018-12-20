#!/bin/bash
set -ex

declare storer_cid=""
declare saver_cid=""
declare porter_cid=""

remove_one_service()
{
  local cid=${1}
  if [ ! -z "${cid}" ]; then
    docker container stop ${cid}       > /dev/null
    docker container rm --force ${cid} > /dev/null
  fi
}
remove_all_services()
{
  remove_one_service ${storer_cid}
  remove_one_service ${saver_cid}
  remove_one_service ${porter_cid}
}
trap remove_all_services EXIT INT

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

error() { >&2 echo ${2}; exit ${1}; }

show_help()
{
  local my_name=`basename "${0}"`
  if [ "${1}" = "--help" ]; then
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
    echo "  \$ ${my_name} port --all"
    echo ""
    exit 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_docker_installed()
{
  if ! hash docker 2> /dev/null; then
    error 1 'ERROR: docker needs to be installed!'
  else
    echo 'Confirmed: docker is installed.'
  fi
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

wait_till_running()
{
  local cid=${1}
  local error_code=${2}
  local n=10
  while [ $(( n -= 1 )) -ge 0 ]
  do
    # Ugh: sleeping first otherwise you can get
    # status=running from container about to exit
    sleep 0.5
    if docker ps --no-trunc --quiet --filter status=running | grep -q ^${cid}$ ; then
      return 0 # true
    fi
  done
  local log=$(docker logs ${cid})
  # TODO: log loses its newlines??
  error ${error_code} ${log}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_unless_storer_preconditions_met()
{
  if running_container storer ; then
    message+="ERROR: The storer service is already running!${newline}"
    message+="Please run $ [sudo] cyber-dojo down${newline}"
    error 2 ${message}
  else
    echo 'Confirmed: the storer service is NOT already running.'
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
    echo 'Confirmed: the saver service is NOT already running'
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
    echo 'Confirmed: the porter service is NOT already running'
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

run_storer_service()
{
  storer_cid=$(docker run \
    --detach \
    --interactive \
    --tty \
      cyberdojo/storer)
  # TODO: with data-container mounted

  wait_till_running ${storer_cid} 6
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_saver_service()
{
  saver_cid=$(docker run \
    --detach \
    --interactive \
    --tty \
    --env DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME} \
    --volume /cyber-dojo:/cyber-dojo \
      cyberdojo/saver)

  wait_till_running ${saver_cid} 7
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_porter_service()
{
  porter_cid=$(docker run \
    --detach \
    --interactive \
    --tty \
    --env DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME} \
    --link ${storer_cid} \
    --link ${saver_cid} \
    --volume /porter:/porter \
      cyberdojo/porter)

  wait_till_running ${porter_cid} 8
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
exit_unless_docker_installed
exit_unless_storer_preconditions_met
exit_unless_saver_preconditions_met
exit_unless_porter_preconditions_met
#TODO: restore this
#pull_latest_images
run_storer_service
run_saver_service
run_porter_service
run_port_exec ${*}
