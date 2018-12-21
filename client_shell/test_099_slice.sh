#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_099_slice()
{
  local name=099
  create_stub_storer_data_container ${name}
  create_root_dir_for_saver_volume_mount ${name}
  create_root_dir_for_porter_volume_mount ${name}

  port --sample10
  assert_stdout_includes 'Hello from port.rb --sample10'
  assert_stdout_includes 'porter.sha=='
  assert_stdout_includes 'storer.sha=='
  assert_stdout_includes 'saver.sha=='
  assert_stderr_equals ''
  assert_status_equals 0

  cleanup ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
