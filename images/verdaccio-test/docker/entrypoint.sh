#!/bin/bash
set -e

DB_FILE="/verdaccio/storage/data/.verdaccio-db.json"

if [[ -n "$VERDACCIO_UID" ]] && [[ "$VERDACCIO_UID" != `id -u node` ]]; then
  echo "Changing user id..."
  usermod -u "$VERDACCIO_UID" node
fi

if [[ ! -e "$DB_FILE" ]]; then
  echo "Creating DB file..."
  echo '{"list": [],"secret": "not-so-secret"}' > "$DB_FILE"
fi

echo "Setting not so secret secret..."
UPDATED=$(cat "$DB_FILE" | jq '.secret = "not-so-secret"')
echo "$UPDATED" > "$DB_FILE"

echo "Fixing file permissions..."
chown -R node:node /verdaccio

exec su - node -c "$@"
