#!/bin/bash

set -e

export PGHOST=$HOMS_DB_HOST
export PGUSER=$HOMS_DB_USER
export PGPASSWORD=$HOMS_DB_PASSWORD

until psql -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up"
