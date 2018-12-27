#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_012_sample_id2_with_porter_info()
{
  local name=012a
  create_stubs_and_insert_test_data ${name} old
  export SHOW_PORTER_INFO=true
  port --id2
  cleanup_stubs ${name}

  assert_stdout_includes_all_up_down
  assert_stdout_line_count_equals 18 # 17 + 1 which is the sample!
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_012_sample_id2_as_user_sees_it()
{
  local name=012b
  create_stubs_and_insert_test_data ${name} old
  export SHOW_PORTER_INFO=false
  port --id2
  cleanup_stubs ${name}

  assert_stdout_equals_id2
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
