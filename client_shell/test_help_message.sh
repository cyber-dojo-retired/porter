#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

. ${MY_DIR}/porter_helpers.sh

readonly help_line="As each session is ported, a single P/E/M character is printed:"

test_help_message()
{
  port --help
  assert_stdout_includes ${help_line}
  assert_stderr_equals ''
  assert_status_equals 0
}

test_help_message_when_no_arguments()
{
  port
  assert_stdout_includes ${help_line}
  assert_stderr_equals ''
  assert_status_equals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
