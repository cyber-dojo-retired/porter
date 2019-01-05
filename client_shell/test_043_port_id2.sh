#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

export SHOW_PORTER_INFO=false

test_043a_port_id2_malformed_not_base58_is_error_status_16()
{
  local name=043a
  local not_base_58=£B
  create_stubs_and_insert_test_data ${name} new
  port --id2 ${not_base_58}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id2 <${not_base_58}> (!Base58)"
  assert_status_equals 16
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_043b_port_id2_malformed_not_size_2_is_error_status_17()
{
  local name=043b
  local not_size_2=12345BCDE
  create_stubs_and_insert_test_data ${name} new
  port --id2 ${not_size_2}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id2 <${not_size_2}> (size==9 !2)"
  assert_status_equals 17
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_043c_port_id2_does_not_exist_is_error_status_18()
{
  local name=043c
  local not_exist=0F
  create_stubs_and_insert_test_data ${name} new
  port --id2 ${not_exist}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: id2 <${not_exist}> does not exist"
  assert_status_equals 18
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_043d_port_id2_all_P_chars()
{
  local name=043d
  local id2=9f
  create_stubs_and_insert_test_data ${name} new
  port --id2 ${id2}
  cleanup_stubs ${name}

  assert_stdout_includes "${id2}:PPPPPPPPP"
  assert_stdout_includes "P(9),M(0),e(0),a(0)"
  assert_stdout_line_count_equals 2
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_043e_port_id2_all_M_chars()
{
  local name=043e
  local id2=0B
  create_stubs_and_insert_test_data ${name} dup_client
  port --id2 ${id2}
  cleanup_stubs ${name}

  assert_stdout_includes "${id2}:MM"
  assert_stdout_includes "P(0),M(2),e(0),a(0)"
  assert_stdout_line_count_equals 2
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_043f_port_id2_all_e_chars()
{
  local name=043d
  local id2=4D
  create_stubs_and_insert_test_data ${name} throws
  port --id2 ${id2}
  cleanup_stubs ${name}

  assert_stdout_includes "${id2}:ee"
  assert_stdout_includes "P(0),M(0),e(2),a(0)"
  assert_stdout_line_count_equals 2
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
