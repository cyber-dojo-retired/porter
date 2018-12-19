#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly MY_NAME=`basename "${0}"`

declare storer_cid=0
declare saver_cid=0
declare porter_cid=0

error() { echo "ERROR: ${2}"; exit ${1}; }

show_use()
{
  # It would be better to have this help inside the porter image...
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
  echo "Note that this port is automated and destructive. As each session"
  echo "is successfully ported to saver it is removed from storer."
  echo "Back up your server before you start?"
  echo
  echo "Start by checking the required preconditions,"
  echo "for example, saver's host dir existence and permissions."
  #     this also needs to check storer is NOT running, viz $ cyber-dojo down
  echo "Follow the instructions till this reports success:"
  echo "  \$ ${MY_NAME} --pre-check"
  echo
  echo "Then move on to porting the practice sessions."
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

check_storer_preconditions()
{
  if docker ps -a | grep storer > /dev/null ; then
    error 2 'The storer service is already running. Please run $ [sudo] cyber-dojo down'
  else
    echo 'Confirmed: the storer service is NOT already running.'
  fi
  # TODO: check data-container exists?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

check_saver_preconditions()
{
  if docker ps -a | grep saver > /dev/null ; then
    error 3 'The saver service is already running! Please run $ [sudo] cyber-dojo down'
  else
    echo 'Confirmed: the saver service is NOT already running'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

check_preconditions()
{
  check_docker_installed
  check_storer_preconditions
  check_saver_preconditions
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
  docker stop ${storer_cid}
  docker rm ${storer_cid}
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
  docker rm ${saver_cid}
}

bring_up_saver_service()
{
  saver_cid=$(docker run \
    --detach \
    --volume /cyber-dojo:/cyber-dojo \
      cyberdojo/saver)

  trap remove_saver_service EXIT INT

  # TODO: check saver-uid has write access to /cyber-dojo (with docker exec)
  #
  #  error 4
  #  'The saver user (uid=???) in the saver service needs write access to /cyber-dojo
  #  'Please run $ [sudo] chmod -R ??? /cyber-dojo'
  #    (if on DockerToolbox with will be on default VM)
  #  else
  #  echo 'Confirmed: the saver user in the saver service has write access to /cyber-dojo'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

remove_porter_service()
{
  docker stop ${porter_cid}
  docker rm ${porter_cid}
}

bring_up_porter_service()
{
  porter_cid=$(docker run \
    --detach \
    --link ${storer_cid} \
    --link ${saver_cid} \
    --volume /porter:/porter \
      cyberdojo/porter)

  trap remove_porter_service EXIT INT

  # TODO: check porter-uid has write access to /porter (with docker exec)
  #
  #  error 4
  #  'The porter user (uid=???) in the porter service needs write access to /porter
  #  'Please run $ [sudo] chmod -R ??? /porter'
  #    (if on DockerToolbox with will be on default VM)
  #  else
  #  echo 'Confirmed: the porter user in the porter service has write access to /porter'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_the_port()
{
  # Note: web will use porter's rack-dispatcher API
  docker exec -it \
    ${porter_cid} \
      sh -c "ruby /app/src/port.rb ${*}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "${1}" = '--help' ];  then
  show_use; exit 0
fi

if [ "${1}" = '--pre-check' ]; then
  check_preconditions; exit 0
fi

check_preconditions
#pull_latest_images
bring_up_storer_service
bring_up_saver_service
bring_up_porter_service
run_the_port
