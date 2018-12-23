#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_004_porter_already_exists()
{
  local name=004
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  docker run --detach --name "${name}-porter" alpine > /dev/null
  port --id10
  docker rm --force "${name}-porter" > /dev/null
  cleanup_stubs ${name}

  assert_stdout_includes_installed docker
  assert_stdout_includes_installed curl
  assert_stdout_includes_storers_data_container_exists
  assert_stdout_includes_not_already_running storer
  assert_stdout_includes_not_already_running saver
  assert_stdout_line_count_equals 5
  assert_stderr_equals_porter_already_running
  assert_status_equals 6
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
