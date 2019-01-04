#!/bin/bash

readonly ARGS=(${*})
readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly TEST_LOG=${COVERAGE_ROOT}/test.log

mkdir -p ${COVERAGE_ROOT}
cd ${MY_DIR}/..
readonly FILES=(*_test.rb)

ruby -e "([ './util/coverage.rb' ] + %w(${FILES[*]})).each{ |file| require './'+file }" \
  -- ${ARGS[@]} | tee ${TEST_LOG}

ruby ${MY_DIR}/check_test_results.rb \
  ${TEST_LOG} \
  ${COVERAGE_ROOT}/index.html \
    > ${COVERAGE_ROOT}/done.txt
