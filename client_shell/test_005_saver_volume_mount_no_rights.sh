#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_005_saver_volume_mount_no_rights()
{
  local name=005
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name} no-chown

  export SHOW_PORTER_INFO=true
  port --id10
  cleanup_stubs ${name}

  assert_stdout_includes_installed docker # 1
  assert_stdout_includes_installed curl # 2
  assert_stdout_includes_storers_data_container_exists # 3
  assert_stdout_includes_not_already_running storer # 4
  assert_stdout_includes_not_already_running saver # 5
  assert_stdout_includes_not_already_running porter # 6
  assert_stdout_includes_the_network_has_been_created # 7
  assert_stdout_includes_ready storer OK # 8
  assert_stdout_includes_ready saver FAIL # 9
  assert_stdout_includes_stopping storer # 10
  assert_stdout_includes_removing storer # 11
  assert_stdout_includes_stopping saver # 12
  assert_stdout_includes_removing saver # 13
  assert_stdout_includes_stopping porter # 14
  assert_stdout_includes_removing porter # 15
  assert_stdout_includes_removing_the_network # 16
  assert_stdout_line_count_equals 16

  assert_stderr_equals_no_rights_to_saver_volume_mount

  assert_status_equals 8
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
