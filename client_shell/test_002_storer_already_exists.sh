#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_002_storer_already_exists()
{
  local name=002
  create_stub_storer_data_container ${name}
  create_root_dir_for_saver_volume_mount ${name}
  create_root_dir_for_porter_volume_mount ${name}

  docker run --detach --name "${name}-storer" alpine > /dev/null
  port --sample10
  docker rm --force "${name}-storer" > /dev/null
  cleanup_stub_data_container_and_stub_volumes ${name}

  assert_stdout_equals ''
  assert_stderr_includes "ERROR: A storer service already exists"
  assert_stderr_includes "Please run $ [sudo] cyber-dojo down"
  assert_status_equals 2
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
