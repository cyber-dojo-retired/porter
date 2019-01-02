#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_008_unknown_args_is_error_status_10()
{
  local name=008
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  export SHOW_PORTER_INFO=true
  port alpha ignored
  cleanup_stubs ${name}

  assert_stdout_includes_all_up_down
  assert_stdout_line_count_equals 17
  assert_stderr_includes 'ERROR: unknown arg <alpha>'
  assert_status_equals 10
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
