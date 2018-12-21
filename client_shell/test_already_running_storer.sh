#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_already_running_storer()
{
  local name=${FUNCNAME[0]}
  docker run --detach --name "${name}" alpine > /dev/null

  port --sample10
  docker rm --force "${name}"
  #dump_sss

  assert_stdout_equals ''

  assert_stderr_includes "ERROR: The storer service is already running"
  assert_stderr_includes "Please run $ [sudo] cyber-dojo down"

  assert_status_equals 2
  #TODO: needs cleanup
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2