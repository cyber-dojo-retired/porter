#!/bin/bash

readonly my_dir="$( cd "$( dirname "${0}" )" && pwd )"

. ${my_dir}/porter_helpers.sh

test_012_port_id10_not_found_with_porter_info()
{
  :
}
test_012_port_id10_not_found_as_user_sees_it()
{
  :
}

test_012_port_id10_ok_with_porter_info()
{
  : # port --id10 14535aeGHP
}
test_012_port_id10_ok_as_user_sees_it()
{
  :
}

test_012_port_id10_mapped_with_porter_info()
{
  :
}
test_012_port_id10_mapped_as_user_sees_it()
{
  :
}

test_012_port_id10_exception_with_porter_info()
{
  :
}
test_012_port_id10_exception_as_user_sees_it()
{
  :
}

. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2
