#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_007_unknown_arg()
{
  local name=007
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  port --nolog alpha
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals 'ERROR: unknown arg <alpha>'
  assert_status_equals 10
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
