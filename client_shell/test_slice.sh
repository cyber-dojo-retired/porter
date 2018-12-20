#!/bin/bash

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
. ${MY_DIR}/porter_helpers.sh

test_slice()
{
  port id42
  assertStdoutIncludes 'Hello from port.rb id42'
  assertStderrEquals ''
  assertStatusEquals 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${MY_DIR}/shunit2_helpers.sh
. ${MY_DIR}/shunit2
