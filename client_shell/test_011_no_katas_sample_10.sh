#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_011_no_katas_sample_10()
{
  local name=011
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  port --nolog --id10
  cleanup_stubs ${name}

  assert_stdout_equals ''
  assert_stderr_equals 'ERROR: storer is empty!'
  assert_status_equals 11
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
