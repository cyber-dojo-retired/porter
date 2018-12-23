#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_009_some_unknown_args()
{
  local name=009
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  port --nolog --id10 alpha
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_includes 'ERROR: unknown arg <alpha>'
  assert_status_equals 10
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
