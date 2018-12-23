#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_004_porter_already_exists()
{
  local name=004
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  docker run --detach --name "${name}-porter" alpine > /dev/null
  port --nolog --id10
  docker rm --force "${name}-porter" > /dev/null
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_includes "ERROR: A porter service already exists"
  assert_stderr_includes "Please run $ [sudo] docker rm -f porter"
  assert_status_equals 5
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
