
assert_stdout_equals()
{
  assertEquals 'stdout' "$1" "`cat ${stdoutF}`"
}

assert_stdout_includes()
{
  local stdout="`cat ${stdoutF}`"
  if [[ "${stdout}" != *"${1}"* ]]; then
    echo "<stdout>"
    cat ${stdoutF}
    echo "</stdout>"
    fail "expected stdout to include ${1}"
  fi
}

assert_stdout_line_count_equals()
{
  assertEquals ${1} $(wc -l ${stdoutF} | awk '{ print $1 }')
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assert_stderr_equals()
{
  assertEquals 'stderr' "$1" "`cat ${stderrF}`"
}

assert_stderr_includes()
{
  local stderr="`cat ${stderrF}`"
  if [[ "${stderr}" != *"${1}"* ]]; then
    echo "<stderr>"
    cat ${stderrF}
    echo "</stderr>"
    fail "expected stderr to include ${1}"
  fi
}

assert_stderr_line_count_equals()
{
  assertEquals ${1} $(wc -l ${stderrF} | awk '{ print $1 }')
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assert_status_equals()
{
  assertEquals 'status' "$1" "`cat ${statusF}`"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

dump_sss()
{
    echo '<stdout>'
    cat "${stdoutF}"
    echo '</stdout>'
    echo '<stderr>'
    cat "${stderrF}"
    echo '</stderr>'
    echo '<status>'
    cat "${statusF}"
    echo '</status>'
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
