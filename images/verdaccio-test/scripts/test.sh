#!/bin/bash

set -euo pipefail

cd "$(dirname $0)/.."

TEST_WORKSPACE="${PWD}/test-workspace"
TEST_FIXTURE="${PWD}/fixtures/docker-compose-project"

# cleanup
function clean_up {
  exit_code=$?
  cd "$TEST_WORKSPACE"
  docker compose logs registry
  docker compose down

  if [[ $exit_code == 0 ]]; then
    echo "🤡  Yay, tests passed"
  fi
  exit $exit_code
}
trap clean_up EXIT

# setup dirs
rm -rf "$TEST_WORKSPACE" || true
cp -r "$TEST_FIXTURE" "$TEST_WORKSPACE"
cd "$TEST_WORKSPACE"

export IMAGE="${IMAGE}"
export VERDACCIO_UID=`id -u`
export VERDACCIO_PORT=5000

docker compose up -d
REGISTRY_HOST=$(docker compose port registry "$VERDACCIO_PORT")
docker compose run --rm registry auth > .npmrc
sed -E -i "s|//[^/]+/|//${REGISTRY_HOST:-}/|g" .npmrc

cd ./basic-package

npm --userconfig "${TEST_WORKSPACE}/.npmrc" --registry "http://${REGISTRY_HOST}" publish

cd "$TEST_WORKSPACE"

function test_ownership {
  owner=$(stat -c '%U' "$1")
  owner_uid=$(id -u $owner)

  if [[ "$owner_uid" != "$VERDACCIO_UID" ]]; then
    echo "expected $1 to be owned by $VERDACCIO_UID. Is owned by $owner_uid"
    exit 1
  fi
}

test_ownership "$TEST_WORKSPACE/data"
test_ownership "$TEST_WORKSPACE/data/.verdaccio-db.json"
test_ownership "$TEST_WORKSPACE/data/basic-package/package.json"



