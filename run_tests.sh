#! /bin/bash

RAILS_ENV=test

/wait_for_postgres.sh db_homs

# prepare configs
cp config/activiti.yml.sample config/activiti.yml
cp config/database.yml.sample config/database.yml
cp config/secrets.yml.sample config/secrets.yml
echo "sources:
  bpmanagementsystem:
    type: 'static/activiti'
" > config/sources.yml

bundle exec rake db:migrate && bundle exec rake db:seed

# add source billing for tests
echo "sources:
  bpmanagementsystem:
    type: 'static/activiti'
  billing:
    type: sql/oracle
    tns_name: test
    username: test
    password: test
" > config/sources.yml

xvfb-run -a bundle exec rspec ./spec --format RspecJunitFormatter --out test-reports/out.xml --format progress --profile

if [ "$GENERATE_DOC" = 'true' ]; then bundle exec rake docs:generate && zip -r doc.zip public/doc; fi
