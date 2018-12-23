#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

readonly help_line1="Ports cyber-dojo practice sessions"
readonly help_line2="As each session is ported, a single P/E/M character is printed:"

test_000_help_message()
{
  port
  assert_stdout_includes "${help_line1}"
  assert_stdout_includes "${help_line2}"
  assert_stderr_equals ''
  assert_status_equals 0

  port --help
  assert_stdout_includes "${help_line1}"
  assert_stdout_includes "${help_line2}"
  assert_stderr_equals ''
  assert_status_equals 0

  port --nolog
  assert_stdout_includes "${help_line1}"
  assert_stdout_includes "${help_line2}"
  assert_stderr_equals ''
  assert_status_equals 0

  port --nolog --help
  assert_stdout_includes "${help_line1}"
  assert_stdout_includes "${help_line2}"
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
