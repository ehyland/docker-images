#!/bin/bash

set -euo pipefail

cd "$(dirname $0)/.."
 
scripts/build.sh

scripts/test.sh

scripts/push.sh