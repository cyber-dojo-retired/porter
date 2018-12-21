#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_415_slice()
{
  local name=${FUNCNAME[0]}

  create_stub_storer_data_container ${name}
  create_root_dir_for_saver_volume_mount ${name}
  create_root_dir_for_porter_volume_mount ${name}

  port id42
  assertStdoutIncludes 'Hello from port.rb id42'
  assertStdoutIncludes 'porter.sha=='
  assertStdoutIncludes 'storer.sha=='
  assertStdoutIncludes 'saver.sha=='
  assertStderrEquals ''
  assertStatusEquals 0

  cleanup ${name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
