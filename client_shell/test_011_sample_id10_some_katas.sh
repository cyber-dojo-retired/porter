#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_011_sample_id10_some_katas_with_porter_info()
{
  local name=011a
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} old

  export SHOW_PORTER_INFO=true
  port --id10
  cleanup_stubs ${name}

  assert_stdout_includes_all_up_down
  assert_stdout_line_count_equals 18 # 17 + 1 which is the sample!
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011_sample_id10_some_katas_as_user_sees_it()
{
  local name=011b
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} old

  export SHOW_PORTER_INFO=false
  port --id10
  cleanup_stubs ${name}

  local id10="`cat ${stdoutF}`"
  assert_id10 "${id10}"
  assert_stdout_line_count_equals 1
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
