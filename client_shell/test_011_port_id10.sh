#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

export SHOW_PORTER_INFO=false

test_011a_port_id10_malformed_not_base58()
{
  local name=011a
  local not_base_58=12345£BCDE
  create_stubs_and_insert_test_data ${name} new
  port --id10 ${not_base_58}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id10 <${not_base_58}> (!Base58)"
  assert_status_equals 11
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011b_port_id10_malformed_not_size_10()
{
  local name=011b
  local not_size_10=12345BCDE
  create_stubs_and_insert_test_data ${name} new
  port --id10 ${not_size_10}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id10 <${not_size_10}> (size==9 !10)"
  assert_status_equals 12
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011c_port_id10_does_not_exist()
{
  local name=011c
  local not_exist=0F44761F81
  create_stubs_and_insert_test_data ${name} new
  port --id10 ${not_exist}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: id10 <${not_exist}> does not exist"
  assert_status_equals 13
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011d_port_id10_P()
{
  local name=011d
  local exists=9fH6TumFV2
  create_stubs_and_insert_test_data ${name} new
  port --id10 ${exists}
  cleanup_stubs ${name}

  assert_stdout_equals 'P'
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011e_port_id10_M()
{
  local name=011e
  local dup1=0BA7E1E01B
  local dup2=0BA7E16149
  create_stubs_and_insert_test_data ${name} dup_client
  port --id10 ${dup1}
  cleanup_stubs ${name}

  assert_stdout_equals 'M'
  assert_stderr_equals ''
  assert_status_equals 0

  create_stubs_and_insert_test_data ${name} dup_client
  port --id10 ${dup2}
  cleanup_stubs ${name}

  assert_stdout_equals 'M'
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_011f_port_id10_E()
{
  local name=011f
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
