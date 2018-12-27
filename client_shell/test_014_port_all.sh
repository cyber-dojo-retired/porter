#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_014_port_all()
{
  local name=014a
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} old # 1F 5A 42
  insert_kata_data_in_storer_data_container ${name} new # 9f
  insert_kata_data_in_storer_data_container ${name} dup_client # 0B
  export SHOW_PORTER_INFO=false
  port --all
  cleanup_stubs ${name}

  assert_stdout_includes '%:1F:P'
  assert_stdout_includes '%:5A:P'
  assert_stdout_includes '%:42:PPPPP'
  assert_stdout_includes '%:9f:PPPPPPPPP'
  assert_stdout_includes '%:0B:MM'
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
