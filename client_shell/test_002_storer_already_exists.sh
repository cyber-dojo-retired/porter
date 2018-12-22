#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_002_storer_already_exists()
{
  local name=001
  docker run --detach --name "${name}-storer" alpine > /dev/null

  port --sample10

  docker rm --force "${name}-storer" > /dev/null
  assert_stdout_equals ''
  assert_stderr_includes "ERROR: A storer service already exists"
  assert_stderr_includes "Please run $ [sudo] cyber-dojo down"
  assert_status_equals 2
  cleanup ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
