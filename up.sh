#!/bin/bash
set -e

if [ ! -d /porter/id-map ]; then
  mkdir /porter/id-map
fi

bundle exec rackup \
  --warn \
  --host 0.0.0.0 \
  --port 4517 \
  --server thin \
  --env production \
    config.ru
