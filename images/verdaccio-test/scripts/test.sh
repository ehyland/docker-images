#!/bin/bash

set -euo pipefail

cd "$(dirname $0)/.."

cat .build-vars
source .build-vars

TEST_WORKSPACE="${PWD}/test-workspace"
TEST_FIXTURE="${PWD}/fixtures/docker-compose-project"

# cleanup
function clean_up {
  cd "$TEST_WORKSPACE"
  docker-compose down
}
trap clean_up EXIT

# setup dirs
rm -rf "$TEST_WORKSPACE" || true
cp -r "$TEST_FIXTURE" "$TEST_WORKSPACE"
cd "$TEST_WORKSPACE"

# more vars
export TAG="${TAG}"
export VERDACCIO_UID=`id -u`
export VERDACCIO_PORT=5000

docker-compose run registry auth > .npmrc

docker-compose up -d

cd ./basic-package

npm --userconfig "${TEST_WORKSPACE}/.npmrc" --registry "http://localhost:5000" publish

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

echo "🤡  Yay, tests passed"


