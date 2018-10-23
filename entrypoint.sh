#!/bin/bash

/wait_for_postgres.sh

cp -rn /tmp/config/* /opt/homs/config/

bundle exec rake db:migrate
yarn install && bundle exec rake assets:precompile

if [[ ! -a seed.lock ]]; then
    bundle exec rake db:seed
    touch seed.lock
fi

bundle exec thin start --threaded
