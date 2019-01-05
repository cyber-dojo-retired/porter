#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

export SHOW_PORTER_INFO=false

test_041a_port_id10_malformed_not_base58_is_error_status_13()
{
  local name=041a
  local not_base_58=12345£BCDE
  create_stubs_and_insert_test_data ${name} new
  port --id10 ${not_base_58}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id10 <${not_base_58}> (!Base58)"
  assert_status_equals 13
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_041b_port_id10_malformed_not_size_10_is_error_status_14()
{
  local name=041b
  local not_size_10=12345BCDE
  create_stubs_and_insert_test_data ${name} new
  port --id10 ${not_size_10}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id10 <${not_size_10}> (size==9 !10)"
  assert_status_equals 14
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_041c_port_id10_does_not_exist_is_error_status_15()
{
  local name=041c
  local not_exist=0F44761F81
  create_stubs_and_insert_test_data ${name} new
  port --id10 ${not_exist}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: id10 <${not_exist}> does not exist"
  assert_status_equals 15
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_041d_port_id10_prints_P_when_ports_with_prefix_id()
{
  local name=041d
  create_stubs_and_insert_test_data ${name} new
  port --id10 9fH6TumFV2
  cleanup_stubs ${name}

  assert_stdout_equals 'P'
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_041e_port_id10_prints_M_when_ports_with_mapped_id()
{
  local name=041e
  create_stubs_and_insert_test_data ${name} dup_client
  port --id10 0BA7E1E01B
  cleanup_stubs ${name}

  assert_stdout_equals 'M'
  assert_stderr_equals ''
  assert_status_equals 0

  create_stubs_and_insert_test_data ${name} dup_client
  port --id10 0BA7E16149
  cleanup_stubs ${name}

  assert_stdout_equals 'M'
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_041f_port_id10_prints_a_when_already_ported()
{
  local name=041f
  create_stubs_and_insert_test_data ${name} new
  port --id10 9fH6TumFV2
  assert_stdout_equals 'P'
  assert_stderr_equals ''
  assert_status_equals 0

  port --id10 9fH6TumFV2
  cleanup_stubs ${name}
  assert_stdout_equals 'a'
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_041g_port_id10_prints_e_when_exception_raised()
{
  local name=041g
  create_stubs_and_insert_test_data ${name} throws
  port --id10 4DFAC32630
  cleanup_stubs ${name}

  assert_stdout_equals 'e'
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
