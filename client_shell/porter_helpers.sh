
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

readonly PORT_STORER_2_SAVER=${MY_DIR}/../port_cyber_dojo_storer_to_saver.sh

port()
{
  ${PORT_STORER_2_SAVER} ${*} # >${stdoutF} 2>${stderrF}
  status=$?
  echo ${status} >${statusF}
}
