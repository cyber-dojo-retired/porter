#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_003_saver_already_exists()
{
  local name=003
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  docker run --detach --name "${name}-saver" alpine > /dev/null
  port --nolog --id10
  docker rm --force "${name}-saver" > /dev/null
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_includes "ERROR: A saver service already exists"
  assert_stderr_includes "Please run $ [sudo] cyber-dojo down"
  assert_status_equals 4
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
