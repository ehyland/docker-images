#!/bin/bash

set -euo pipefail

cd "$(dirname $0)/.."

TEST_FIXTURE="${PWD}/fixtures/docker-compose-project"
TEST_WORKSPACE="${PWD}/test-workspace"

export COMPOSE_PROJECT_NAME="${BUILDKITE_JOB_ID:-}"
export IMAGE="${IMAGE}"
export VERDACCIO_UID=1000
export VERDACCIO_PORT=5000

# setup dirs
rm -rf "$TEST_WORKSPACE" || true
cp -r "$TEST_FIXTURE" "$TEST_WORKSPACE"
cd "$TEST_WORKSPACE"

# create npmrc
docker compose run --rm registry npmrc "registry:${VERDACCIO_PORT}" > basic-package/.npmrc

docker compose up --exit-code-from test-runner



