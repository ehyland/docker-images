#!/usr/bin/env bash

set -euo pipefail

# install node
fnm install $(cat .nvmrc)

# enable corepack
corepack enable
