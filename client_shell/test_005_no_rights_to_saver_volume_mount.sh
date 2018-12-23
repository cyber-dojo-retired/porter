#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_005_no_rights_to_saver_volume_mount()
{
  local name=005
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name} no-chown

  port --id10
  cleanup_stubs ${name}

  assert_stdout_includes_docker_installed # 1
  assert_stdout_includes_curl_installed # 2
  assert_stdout_includes_storers_data_container_exists # 3
  assert_stdout_includes_storer_not_already_running # 4
  assert_stdout_includes_saver_not_already_running # 5
  assert_stdout_includes_porter_not_already_running # 6
  assert_stdout_includes_the_network_has_been_created # 7
  assert_stdout_includes_storer_running # 8
  assert_stdout_includes_saver_running # (no OK) # 9
  assert_stdout_includes_stopping_storer # 10
  assert_stdout_includes_removing_storer # 11
  assert_stdout_includes_stopping_saver # 12
  assert_stdout_includes_removing_saver # 13
  assert_stdout_includes_removing_the_network # 14
  assert_stdout_line_count_equals 14

  assert_stderr_equals_no_rights_to_saver_volume_mount

  assert_status_equals 7
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
