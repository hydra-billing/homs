#!/bin/bash

set -e

host="$1"

until psql -h "$host" -U "homs" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up"
exit 0
