#!/bin/bash
set -e

echo ""
echo "Starting verdaccio..."
echo ""
echo "  Add the following to your .npmrc for static auth"
echo '  //localhost:4873/:_authToken="T/ZceTDgZFqHEFyzQ5DE0A=="'
echo ""

verdaccio --listen "0.0.0.0:4873" --config "/verdaccio/config.yml"