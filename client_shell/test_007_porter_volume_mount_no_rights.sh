#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_007_porter_volume_mount_no_rights_is_error_status_11()
{
  local name=007
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name} no-chown

  export SHOW_PORTER_INFO=true
  port --id10
  cleanup_stubs ${name}

  assert_stdout_includes_installed docker # 1
  assert_stdout_includes_installed curl # 2
  assert_stdout_includes_storers_data_container_exists # 3
  assert_stdout_includes_not_already_running storer # 4
  assert_stdout_includes_not_already_running mapper # 5
  assert_stdout_includes_not_already_running saver # 6
  assert_stdout_includes_not_already_running porter # 7
  assert_stdout_includes_the_network_has_been_created # 8
  assert_stdout_includes_ready storer OK # 9
  assert_stdout_includes_ready mapper OK # 10
  assert_stdout_includes_ready saver OK # 11
  assert_stdout_includes_ready porter FAIL # 12
  assert_stdout_includes_stopping storer # 13
  assert_stdout_includes_removing storer # 14
  assert_stdout_includes_stopping mapper # 15
  assert_stdout_includes_removing mapper # 16
  assert_stdout_includes_stopping saver # 17
  assert_stdout_includes_removing saver # 18
  assert_stdout_includes_stopping porter # 19
  assert_stdout_includes_removing porter # 20
  assert_stdout_includes_removing_the_network # 21
  assert_stdout_line_count_equals 21
  assert_stderr_equals_no_rights_to_porter_volume_mount
  assert_status_equals 11
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
