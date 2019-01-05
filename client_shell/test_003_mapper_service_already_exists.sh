#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_003_mapper_service_already_exists_is_error_status_5()
{
  local name=005
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  docker run --detach --name "${name}-mapper" alpine > /dev/null
  export SHOW_PORTER_INFO=true
  port --id10
  docker rm --force "${name}-mapper" > /dev/null
  cleanup_stubs ${name}

  assert_stdout_includes_installed docker
  assert_stdout_includes_installed curl
  assert_stdout_includes_storers_data_container_exists
  assert_stdout_includes_not_already_running storer
  assert_stdout_line_count_equals 4
  assert_stderr_equals_mapper_already_running
  assert_status_equals 5
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
