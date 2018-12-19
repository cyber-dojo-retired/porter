#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/porter_helpers.sh

test_one()
{
  echo "Hello from test_one"
  # For each test...
  # insert appropriate data into storer using insert_katas_test_data.sh
  ${PORTS2S} id42
  # call port_cyber_dojo_storer_to_saver.sh ID
  # verify state of saver.   via API curl? via docker exec? (docker-machine ssh default)
  # verify state of storer.
  # verify stdout/stderr/status
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
