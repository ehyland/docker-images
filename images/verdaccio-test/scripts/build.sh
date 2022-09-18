#!/bin/bash

set -euo pipefail

cd "$(dirname $0)/.."

VERDACCIO_VERSION=$(
  curl -fsSL https://registry.npmjs.org/verdaccio/latest \
    | jq -r '.version'
)

TAG="ehyland/verdaccio-test:${VERDACCIO_VERSION}"

docker build \
  -t "$TAG" \
  --build-arg VERDACCIO_VERSION="$VERDACCIO_VERSION" \
  .

if [[ "$1" == "run" ]]; then 
  docker run --rm -it \
    -p 4873:4873 \
    -v $(pwd)/data:/verdaccio/storage/data \
    -e VERDACCIO_UID=`id -u` \
    "$TAG"
fi

if [[ "$1" == "push" ]]; then 
  docker push $TAG
fi

