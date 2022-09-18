#!/bin/bash

set -euo pipefail

cd "$(dirname $0)/.."

cat .build-vars
source .build-vars

docker tag "$TAG" "$LATEST_TAG"
docker push "$TAG"
docker push "$LATEST_TAG"

CODE='`'
echo ":rocket: ${CODE}${TAG}${CODE}" >> $GITHUB_STEP_SUMMARY
echo ":rocket: ${CODE}${LATEST_TAG}${CODE}" >> $GITHUB_STEP_SUMMARY