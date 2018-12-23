#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_005_no_rights_to_saver_volume_mount()
{
  local name=005
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name} no-chown

  port --nolog --id10
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_includes 'ERROR'
  assert_stderr_includes "The saver service needs write access to /cyber-dojo"
  assert_stderr_includes "username=saver (uid=19663)"
  assert_stderr_includes "group=nogroup (gid=65533)"
  assert_stderr_includes "Please run:"
  assert_stderr_includes "  \$ [sudo] chown 19663:65533 /cyber-dojo"
  assert_status_equals 7
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
