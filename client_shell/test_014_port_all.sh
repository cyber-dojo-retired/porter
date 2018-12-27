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
  insert_kata_data_in_storer_data_container ${name} throws # 4D

  export SHOW_PORTER_INFO=false
  port --all
  cleanup_stubs ${name}

  assert_stdout_includes '0%:0B:MM'
  assert_stdout_includes 'P(0),M(2),E(0)'

  assert_stdout_includes '2%:1F:P'
  assert_stdout_includes 'P(1),M(0),E(0)'

  assert_stdout_includes '6%:42:PPPPP'
  assert_stdout_includes 'P(5),M(0),E(0)'

  assert_stdout_includes '7%:4D:EE'
  assert_stdout_includes 'P(0),M(0),E(2)'

  assert_stdout_includes '8%:5A:P'
  assert_stdout_includes 'P(1),M(0),E(0)'

  assert_stdout_includes '16%:9f:PPPPPPPPP'
  assert_stdout_includes 'P(9),M(0),E(0)'

  assert_stdout_includes 'total: P(16),M(2),E(2)'
  assert_stdout_line_count_equals 6729
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
