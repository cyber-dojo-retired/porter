#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_004_no_data_container()
{
  port --sample10

  assert_stdout_equals ''
  assert_stderr_includes "ERROR: Cannot find storer's data-container cyber-dojo-katas-DATA-CONTAINER"
  assert_status_equals 3
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
