#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

readonly network_name="port_cyber_dojo_storer_to_saver"

test_010_log_before_actual_call()
{
  local name=010
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  # don't use --nolog
  port --10
  cleanup_stubs ${name}

  assert_stdout_includes "Confirmed: docker is installed"
  assert_stdout_includes "Confirmed: curl is installed"
  assert_stdout_includes "Confirmed: network ${network_name} has been created"
  assert_stdout_includes "Confirmed: the storer service is not already running"
  assert_stdout_includes "Confirmed: found the storer data-container"
  assert_stdout_includes "Confirmed: the saver service is not already running"
  assert_stdout_includes "Confirmed: the porter service is not already running"
  assert_stdout_includes "Starting the storer service"
  assert_stdout_includes "Confirmed: the storer service is running"
  assert_stdout_includes "Starting the saver service"
  assert_stdout_includes "Confirmed: the saver service is running"
  assert_stdout_includes "Starting the porter service"
  assert_stdout_includes "Confirmed: the porter service is running"
  assert_stdout_includes "Stopping service storer"
  assert_stdout_includes "Removing service storer"
  assert_stdout_includes "Stopping service saver"
  assert_stdout_includes "Removing service saver"
  assert_stdout_includes "Stopping service porter"
  assert_stdout_includes "Removing service porter"
  assert_stdout_includes "Removing network ${network_name}"

  assert_stderr_equals 'ERROR: storer is empty!'
  assert_status_equals 11
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
