#!/bin/bash
set -e

readonly MY_NAME=`basename "${0}"`

declare storer_cid=0
declare saver_cid=0
declare porter_cid=0

error() { echo "ERROR:"$'\n'" ${2}"; exit ${1}; }

show_use()
{
  echo
  echo "Ports cyber-dojo practice sessions from their old format to their new format."
  echo "The old format used:"
  echo "  o) 10-digit ids"
  echo "  o) the storer service"
  echo "  o) a docker data-container."
  echo "The new format uses:"
  echo "  o) 6-digit ids (with a larger alphabet)"
  echo "  o) the saver service"
  echo "  o) a volume-mounted host dir"
  echo
  echo "Note that porting is automated and destructive. As each session"
  echo "is successfully ported to saver it is removed from storer."
  echo "?Back up your server before you start?"
  echo
  echo "As each session is ported, a single P/E/M character will be printed:"
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
  echo "  \$ ${MY_NAME} --show10"
  echo "Then try porting it."
  echo "For example, if the 10-digit id is 9f8TeZMZA2"
  echo "  \$ ${MY_NAME} 9f8TeZMZA2"
  echo
  echo "If all is well, you can move on to porting all"
  echo "the sessions with a given 2-digit prefix."
  echo "To show a randomly selected 2-digit id:"
  echo "  \$ ${MY_NAME} --show2"
  echo "Then try porting them."
  echo "For example, if the 2-digit prefix is 5A"
  echo "  \$ ${MY_NAME} 5A"
  echo
  echo "If all is well, you can move on to porting storer to saver completely:"
  echo "  \$ ${MY_NAME} port --all"
  echo ""
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

check_docker_installed()
{
  if ! hash docker 2> /dev/null; then
    error 1 'docker needs to be installed!'
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

check_storer_preconditions()
{
  if running_container storer ; then
    message+="The storer service is already running!${newline}"
    message+="Please run $ [sudo] cyber-dojo down${newline}"
    error 2 ${message}
  else
    echo 'Confirmed: the storer service is NOT already running.'
  fi
  # TODO: 3. check data-container exists?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

check_saver_preconditions()
{
  if running_container saver ; then
    message+="The saver service is already running!${newline}"
    message+="Please run $ [sudo] cyber-dojo down${newline}"
    error 4 ${message}
  else
    echo 'Confirmed: the saver service is NOT already running'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

check_porter_preconditions()
{
  if running_container porter ; then
    message+="The porter service is already running!${newline}"
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

remove_storer_service()
{
  docker container stop ${storer_cid}
  docker container rm --force ${storer_cid}
}

bring_up_storer_service()
{
  storer_cid=$(docker run \
    --detach \
      cyberdojo/storer)
  # TODO: with data-container mounted
  trap remove_storer_service EXIT INT
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

remove_saver_service()
{
  docker stop ${saver_cid}
  docker container rm --force ${saver_cid}
}

bring_up_saver_service()
{
  saver_cid=$(docker run \
    --detach \
    --env DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME} \
    --volume /cyber-dojo:/cyber-dojo \
      cyberdojo/saver)

  trap remove_saver_service EXIT INT
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

remove_porter_service()
{
  docker container stop ${porter_cid}
  docker container rm --force ${porter_cid}
}

bring_up_porter_service()
{
  porter_cid=$(docker run \
    --detach \
    --env DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME} \
    --link ${storer_cid} \
    --link ${saver_cid} \
    --volume /porter:/porter \
      cyberdojo/porter)

  trap remove_porter_service EXIT INT
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_the_port()
{
  # Note: web will use porter's rack-dispatcher API, we don't
  docker exec -it \
    ${porter_cid} \
      sh -c "ruby /app/src/port.rb ${*}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "${1}" = '--help' ];  then
  show_use; exit 0
fi

check_docker_installed
check_storer_preconditions
check_saver_preconditions
check_porter_preconditions
#pull_latest_images
bring_up_storer_service
bring_up_saver_service
bring_up_porter_service
run_the_port
