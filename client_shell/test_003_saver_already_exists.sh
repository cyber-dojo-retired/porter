#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_003_saver_already_exists()
{
  local name=002
  create_stub_storer_data_container ${name}
  create_root_dir_for_saver_volume_mount ${name}
  docker run --detach --name "${name}-saver" alpine > /dev/null

  port --sample10

  docker rm --force "${name}-saver" > /dev/null
  assert_stdout_equals ''
  assert_stderr_includes "ERROR: A saver service already exists"
  assert_stderr_includes "Please run $ [sudo] cyber-dojo down"
  assert_status_equals 4
  cleanup ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
