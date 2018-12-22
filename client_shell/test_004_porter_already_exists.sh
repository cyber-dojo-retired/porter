#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_004_porter_already_exists()
{
  local name=004
  create_stub_storer_data_container ${name}
  create_root_dir_for_saver_volume_mount ${name}
  create_root_dir_for_porter_volume_mount ${name}

  docker run --detach --name "${name}-porter" alpine > /dev/null
  port --sample10
  docker rm --force "${name}-porter" > /dev/null
  cleanup_stub_data_container_and_stub_volumes ${name}

  assert_stdout_equals ''
  assert_stderr_includes "ERROR: A porter service already exists"
  assert_stderr_includes "Please run $ [sudo] docker rm -f porter"
  assert_status_equals 5
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
