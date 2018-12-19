#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/porter_helpers.sh

test_help_message()
{
  port --help
  assertStdoutIncludes 'Note that this port is automated and destructive'
  assertStderrEquals ''
  assertStatusEquals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
