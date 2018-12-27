#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_013a_port_id2_malformed_not_base58()
{
  local name=015a
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} new

  export SHOW_PORTER_INFO=false
  local not_base_58=£B
  port --id2 ${not_base_58}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id2 <${not_base_58}> (!Base58)"
  assert_status_equals 14
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_013b_port_id2_malformed_not_size_2()
{
  local name=013b
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} new

  export SHOW_PORTER_INFO=false
  local not_size_2=12345BCDE
  port --id2 ${not_size_2}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: malformed id2 <${not_size_2}> (size==9 !2)"
  assert_status_equals 15
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_013c_port_id2_does_not_exist()
{
  local name=013c
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} new

  export SHOW_PORTER_INFO=false
  local not_exist=0F
  port --id2 ${not_exist}
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals "ERROR: id2 <${not_exist}> does not exist"
  assert_status_equals 16
}

# - - - - - - - - - - - - - - - - - - - - - - - -

test_013d_port_id2_all_Ps()
{
  :
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
