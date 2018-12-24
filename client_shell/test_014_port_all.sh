#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

x_test_014_port_all_with_porter_info()
{
  local name=014a
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} old

  export SHOW_PORTER_INFO=true
  port --all
  cleanup_stubs ${name}

  assert_stdout_includes_all_up_down
  assert_stdout_line_count_equals 18 # 17 + 1 which is the sample!
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

x_test_014_port_all_as_user_sees_it()
{
  local name=014b
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} old

  export SHOW_PORTER_INFO=false
  port --id2
  cleanup_stubs ${name}

  assert_stdout_equals_id2
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
