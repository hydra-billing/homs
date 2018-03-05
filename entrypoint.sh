#!/bin/bash

cp -rn /tmp/config/* /opt/homs/config/

cp -n config/activiti.yml.sample config/activiti.yml
[[ -n $ACTIVITI_HOST ]] && sed -i -e "s/localhost/$ACTIVITI_HOST/" config/activiti.yml
[[ -n $ACTIVITI_USER ]] && sed -i -e "s/user/$ACTIVITI_USER/" config/activiti.yml
[[ -n $ACTIVITI_PASS ]] && sed -i -e "s/changeme/$ACTIVITI_PASSWORD/" config/activiti.yml

cp -n config/database.yml.sample config/database.yml
[[ -n $DB_HOST ]] && sed -i -e "s/localhost/$DB_HOST/" config/database.yml

bundle exec rake db:migrate

if [[ ! -a seed.lock ]]; then
    bundle exec rake db:seed
    touch seed.lock
fi

bundle exec thin start --threaded -e ${RACK_ENV:-development}
