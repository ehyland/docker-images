#!/bin/bash

set -euo pipefail

cd "$(dirname $0)/.."

SUB_COMMAND=${1:-}
VERDACCIO_VERSION=$(
  curl -fsSL https://registry.npmjs.org/verdaccio/latest \
    | jq -r '.version'
)

NAME="ehyland/verdaccio-test"
TAG="${NAME}:${VERDACCIO_VERSION}"
LATEST_TAG="${NAME}:latest"

docker pull "$TAG" || true
docker pull "$LATEST_TAG" || true

docker build \
  -t "$TAG" \
  --cache-from "$TAG" \
  --cache-from "$LATEST_TAG" \
  --build-arg VERDACCIO_VERSION="$VERDACCIO_VERSION" \
  .

if [[ "$SUB_COMMAND" == "run" ]]; then 
  docker run --rm -it \
    -p 5000:5000 \
    -v $(pwd)/data:/verdaccio/storage/data \
    -e VERDACCIO_UID=`id -u` \
    -e VERDACCIO_PORT=5000 \
    "$TAG"
fi

if [[ "$SUB_COMMAND" == "push" ]]; then 
  docker tag "$TAG" "$LATEST_TAG"
  docker push "$TAG"
  docker push "$LATEST_TAG"

  CODE='`'
  echo ":rocket: ${CODE}${TAG}${CODE}" >> $GITHUB_STEP_SUMMARY
  echo ":rocket: ${CODE}${LATEST_TAG}${CODE}" >> $GITHUB_STEP_SUMMARY
fi

