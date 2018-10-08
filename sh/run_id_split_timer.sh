#!/bin/bash

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly FILENAME=id_split_timer.rb
readonly TMP_DIR=/tmp
readonly ID_SIZE=${1:-6}
readonly ALL_MAX=${2:-2000}
readonly SAMPLE_MAX=${3:-3}

docker run \
  --rm \
  --user nobody \
  --read-only \
  --volume ${MY_DIR}/${FILENAME}:${TMP_DIR}/${FILENAME} \
  --tmpfs ${TMP_DIR} \
  ruby:alpine \
    ruby ${TMP_DIR}/${FILENAME} ${TMP_DIR} ${ID_SIZE} ${ALL_MAX} ${SAMPLE_MAX}
