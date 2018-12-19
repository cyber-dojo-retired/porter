
assertStdoutEquals() { assertEquals 'stdout' "$1" "`cat ${stdoutF}`"; }
assertStderrEquals() { assertEquals 'stderr' "$1" "`cat ${stderrF}`"; }
assertStatusEquals() { assertEquals 'status' "$1" "`cat ${statusF}`"; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assertStdoutIncludes()
{
  local stdout="`cat ${stdoutF}`"
  if [[ "${stdout}" != *"${1}"* ]]; then
    echo "<stdout>"
    cat ${stdoutF}
    echo "</stdout>"
    fail "expected stdout to include ${1}"
  fi
}

assertStderrIncludes()
{
  local stderr="`cat ${stderrF}`"
  if [[ "${stderr}" != *"${1}"* ]]; then
    echo "<stderr>"
    cat ${stderrF}
    echo "</stderr>"
    fail "expected stderr to include ${1}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

oneTimeSetUp()
{
  outputDir="${SHUNIT_TMPDIR}/output"
  mkdir "${outputDir}"
  stdoutF="${outputDir}/stdout"
  stderrF="${outputDir}/stderr"
  statusF="${outputDir}/status"
  testDir="${SHUNIT_TMPDIR}/some_test_dir"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

absPath()
{
  #use like this [ local resolved=`abspath ./../a/b/c` ]
  cd "$(dirname "$1")"
  printf "%s/%s\n" "$(pwd)" "$(basename "$1")"
}
