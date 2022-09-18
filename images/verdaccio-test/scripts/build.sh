#!/bin/bash

set -euo pipefail

cd "$(dirname $0)/.."

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

if [[ "$1" == "run" ]]; then 
  docker run --rm -it \
    -p 4873:4873 \
    -v $(pwd)/data:/verdaccio/storage/data \
    -e VERDACCIO_UID=`id -u` \
    "$TAG"
fi

if [[ "$1" == "push" ]]; then 
  docker tag "$TAG" "$LATEST_TAG"
  docker push "$TAG"
  docker push "$LATEST_TAG"

  echo "### Published :rocket: ${TAG}" >> $GITHUB_STEP_SUMMARY
  echo "### Published :rocket: ${LATEST_TAG}" >> $GITHUB_STEP_SUMMARY
fi

