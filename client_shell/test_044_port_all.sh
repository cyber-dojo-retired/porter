#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_044_port_all()
{
  local name=044a
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}
  insert_kata_data_in_storer_data_container ${name} old # 1F 5A 42
  insert_kata_data_in_storer_data_container ${name} new # 9f
  insert_kata_data_in_storer_data_container ${name} dup_client # 0B
  insert_kata_data_in_storer_data_container ${name} throws # 4D

  export SHOW_PORTER_INFO=false
  port --id10 9fH6TumFV2
  insert_kata_data_in_storer_data_container ${name} new # 9f
  # now 9fH6TumFV2  is 'a'lready ported
  port --all
  cleanup_stubs ${name}

  assert_stdout_includes '0%:0B:MM'
  assert_stdout_includes 'P(0),M(2),e(0),a(0)'
  assert_stdout_includes '2%:1F:P'
  assert_stdout_includes 'P(1),M(0),e(0),a(0)'
  assert_stdout_includes '6%:42:PPPPP'
  assert_stdout_includes 'P(5),M(0),e(0),a(0)'
  assert_stdout_includes '7%:4D:ee'
  assert_stdout_includes 'P(0),M(0),e(2),a(0)'
  assert_stdout_includes '8%:5A:P'
  assert_stdout_includes 'P(1),M(0),e(0),a(0)'
  assert_stdout_includes '16%:9f:PPPaPPPPP'
  assert_stdout_includes 'P(8),M(0),e(0),a(1)'
  assert_stdout_includes 'total: P(15),M(2),e(2),a(1)'

  assert_stdout_line_count_equals 13
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
