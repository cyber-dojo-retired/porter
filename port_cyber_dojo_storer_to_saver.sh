#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly MY_NAME=`basename "${0}"`

error() { echo "ERROR: ${2}"; exit ${1}; }

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
  echo "Note that this port is automated and destructive. As each session"
  echo "is successfully ported to saver it is removed from storer."
  echo "Consider backup up your server before you start."
  echo
  echo "Start by checking saver's host dir existence and permissions."
  echo "Follow the instructions till this reports success:"
  echo "  \$ ${MY_NAME} --host-dir"
  echo
  echo "Then move on to porting the practice sessions."
  echo "As each session is ported, a single P/E/M character will be printed:"
  echo
  echo "   P - The session ported ok."
  echo "       This means the new 6-digit id is the 1st 6 chars of the 10-digit id."
  echo "       For example 9f8TeZMZA2 --> 9f8TeZ"
  echo
  echo "   M - The session ported ok but needed an id-map."
  echo "       This means the new 6-digit is NOT the 1st 6 chars of the 10-digit id."
  echo "       For example 9f8TeZMZA2 -> uQMecK"
  echo "       ...EXPLAIN WHERE THIS INFO IS HELD..."
  echo
  echo "   E - The session failed to port."
  echo "       An exception arose and the session is still in the storer."
  echo "       ...EXPLAIN WHERE THIS INFO IS HELD..."
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

if [ "${1}" = '--help' ];  then
  show_use; exit 0
fi

# (does this mean it must not be an exception to try and port
# an id that has already been ported)

# check docker installed

# check data-container exists
# check storer service is NOT already up
# docker pull cyberdojo/storer (to get eg kata_delete)
# bring up storer service

# docker pull cyberdojo/saver
# make sure /cyber-dojo dir exists
# bring up saver service and volume-mount /cyber-dojo dir
# check saver-uid has write access to /cyber-dojo (with docker exec)
#    (if on DockerToolbox with will be on default VM)

# docker pull cyberdojo/porter
# make sure /id-map exists (??? OR PUT JSON FILES IN /tmp ???)
# bring up porter container - needs to link to storer and saver
# check porter-uid has write access to /id-map (with docker exec)
#    (if on DockerToolbox with will be on default VM)
# docker exec -it porter-container sh -c 'ruby /app/port.rb ${*}'

# always remove porter container
# always remove saver container
