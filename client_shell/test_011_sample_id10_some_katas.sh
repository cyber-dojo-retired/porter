#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_011_sample_id10_no_katas()
{
  local name=011
  create_stub_storer_data_container ${name}
  create_stub_saver_volume_mount_root_dir ${name}
  create_stub_porter_volume_mount_root_dir ${name}

  local dc_name=$(get_data_container_name "${name}")
  local cid=$(docker run --detach --interactive --name jj \
    --volumes-from ${dc_name} \
      cyberdojo/storer sh)
  ${my_dir}/../inserter/insert.sh jj old
  docker container rm --force ${cid} > /dev/null

  export SHOW_PORTER_INFO=true
  port --id10
  cleanup_stubs ${name}

  assert_stdout_includes_all_up_down
  assert_stdout_line_count_equals 18 # 17 + 1 which is the sample!
  assert_stderr_equals ''
  assert_status_equals 0
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
