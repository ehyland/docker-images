#!/bin/bash

set -euo pipefail

cd "$(dirname $0)/.."

TEST_WORKSPACE="$PWD"

cd ./basic-package

# wait for registry to start
sleep 1

npm publish

cd "$TEST_WORKSPACE"

function test_ownership {
  owner=$(stat -c '%U' "$1")
  owner_uid=$(id -u $owner)
  if [[ "$owner_uid" != "$VERDACCIO_UID" ]]; then
    echo "expected $1 to be owned by $VERDACCIO_UID. Is owned by $owner_uid"
    exit 1
  else 
    echo "✅  $1 is owned by $VERDACCIO_UID"
  fi
}

test_ownership "$TEST_WORKSPACE/data"
test_ownership "$TEST_WORKSPACE/data/.verdaccio-db.json"
test_ownership "$TEST_WORKSPACE/data/basic-package/package.json"

