#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/porter_helpers.sh

readonly help_line1="As each session is ported, a single P/E/M character is printed:"
readonly help_line2="Ports cyber-dojo practice sessions"

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

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
