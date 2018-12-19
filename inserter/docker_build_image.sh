#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

docker build \
  --tag cyberdojo/storer-inserter \
  ${MY_DIR}
