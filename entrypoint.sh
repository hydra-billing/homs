#!/bin/bash

/wait_for_postgres.sh

cp -rn /tmp/config/* /opt/homs/config/

bundle exec rails db:migrate

if [[ ! -a seed.lock ]]; then
    bundle exec rails db:seed
    touch seed.lock
fi

bundle exec unicorn -E production -c config/unicorn.rb
