#!/bin/bash
set -e

DB_FILE="/verdaccio/storage/data/.verdaccio-db.json"
CONFIG_FILE="/verdaccio/config.yml"
VERDACCIO_PORT=${VERDACCIO_PORT:-"4873"}

if [[ "${1:-}" == "auth" ]]; then
  echo ""
  echo '//localhost:'$VERDACCIO_PORT'/:_authToken="T/ZceTDgZFqHEFyzQ5DE0A=="'
  echo ""
  exit 0
fi

if [[ -n "$VERDACCIO_UID" ]] && [[ "$VERDACCIO_UID" != `id -u node` ]] && [[ "$VERDACCIO_UID" != 0 ]]; then
  echo "Changing user id..."
  usermod -u "$VERDACCIO_UID" node
fi

if [[ ! -e "$DB_FILE" ]]; then
  echo "Creating DB file..."
  echo '{"list": [],"secret": "not-so-secret"}' > "$DB_FILE"
fi

echo "Setting not so secret secret..."
yq -o=json -i '.secret = "not-so-secret"' "$DB_FILE"

echo "Setting correct listen config..."
yq -i '.listen = ["0.0.0.0:'$VERDACCIO_PORT'"]' "$CONFIG_FILE"

if [[ -n "$VERDACCIO_NO_NPM_PROXY_PACKAGE" ]]; then
  echo "Updating config to disable proxy for $VERDACCIO_NO_NPM_PROXY_PACKAGE..."

  yq -i \
    '.packages = {
      "'$VERDACCIO_NO_NPM_PROXY_PACKAGE'": {
        "access": "$all",
        "publish": "$all",
        "unpublish": "$authenticated"
      }
    } + .packages' \
    "$CONFIG_FILE"
fi

echo "Fixing file permissions..."
chown -R node:node /verdaccio

exec su - node -c "$@"
