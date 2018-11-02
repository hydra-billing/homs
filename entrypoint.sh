#!/bin/bash

/wait_for_postgres.sh

cp -rn /tmp/config/* /opt/homs/config/

yarn install && bundle exec rails db:migrate && bundle exec rails assets:precompile

if [[ ! -a seed.lock ]]; then
    bundle exec rails db:seed
    touch seed.lock
fi

bundle exec thin start --threaded
