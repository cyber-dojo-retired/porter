
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

readonly PORT_STORER_2_SAVER=${MY_DIR}/../port_cyber_dojo_storer_to_saver.sh

port()
{
  echo "port() called..."
  ${PORT_STORER_2_SAVER} $* >${stdoutF} 2>${stderrF};
}

assert()
{
  if [ "$1" == "0" ]; then
    echo "<stdout>"
    cat ${stdoutF}
    echo "</stdout>"
    echo "<stderr>"
    cat ${stderrF}
    echo "</stderr>"
    #TODO: print 'original' arguments
    assertTrue 1
  fi
}

refute()
{
  if [ "$1" == "0" ]; then
    echo "<stdout>"
    cat ${stdoutF}
    echo "</stdout>"
    echo "<stderr>"
    cat ${stderrF}
    echo "</stderr>"
    #TODO: print 'original' arguments
    assertFalse 0
  fi
}
