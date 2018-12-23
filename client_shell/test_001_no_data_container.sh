#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_001_no_data_container()
{
  port --nolog --id10

  assert_stdout_equals ''
  assert_stderr_equals_cant_find_storers_data_container
  assert_status_equals 3
}

# - - - - - - - - - - - - - - - - - - - - - - -

test_001_no_data_container_with_log()
{
  port --id10

  assert_stdout_includes_docker_installed
  assert_stdout_includes_curl_installed
  assert_stdout_includes_storer_not_running
  assert_stdout_line_count_equals 3
  assert_stderr_equals_cant_find_storers_data_container
  assert_status_equals 3
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
