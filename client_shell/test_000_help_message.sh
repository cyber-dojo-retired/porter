#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_000_help_message()
{
  local help_line1="Ports cyber-dojo practice sessions:"
  local help_line2="As each session is ported, a single character is printed:"

  port
  assert_stdout_includes "${help_line1}"
  assert_stdout_includes "${help_line2}"
  assert_stdout_line_count_equals 51
  assert_stderr_equals ''
  assert_status_equals 0

  port --help
  assert_stdout_includes "${help_line1}"
  assert_stdout_includes "${help_line2}"
  assert_stdout_line_count_equals 51
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
