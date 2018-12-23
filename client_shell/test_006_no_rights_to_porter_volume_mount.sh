#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_006_no_rights_to_porter_volume_mount()
{
  local name=006
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name} no-chown

  port --nolog --id10
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_includes 'ERROR'
  assert_stderr_includes "The porter service needs write access to /porter"
  assert_stderr_includes "username=porter (uid=19664)"
  assert_stderr_includes "group=nogroup (gid=65533)"
  assert_stderr_includes "Please run:"
  assert_stderr_includes "  \$ [sudo] chown 19664:65533 /porter"
  assert_status_equals 8
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
