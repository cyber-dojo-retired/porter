#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_006_no_rights_to_porter_volume_mount()
{
  local name=006
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name} no-chown

  port --id10
  cleanup_stubs ${name}

  assert_stdout_includes_docker_installed # 1
  assert_stdout_includes_curl_installed # 2
  assert_stdout_includes_storers_data_container_exists # 3
  assert_stdout_includes_not_already_running storer # 4
  assert_stdout_includes_not_already_running saver # 5
  assert_stdout_includes_not_already_running porter # 6
  assert_stdout_includes_the_network_has_been_created # 7
  assert_stdout_includes_running storer OK # 8
  assert_stdout_includes_running saver OK # 9
  assert_stdout_includes_running porter FAIL # 10
  assert_stdout_includes_stopping storer # 11
  assert_stdout_includes_removing storer # 12
  assert_stdout_includes_stopping saver # 13
  assert_stdout_includes_removing saver # 14
  assert_stdout_includes_stopping porter # 15
  assert_stdout_includes_removing porter # 16
  assert_stdout_includes_removing_the_network # 17
  assert_stdout_line_count_equals 17
  assert_stderr_equals_no_rights_to_porter_volume_mount
  assert_status_equals 8
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
