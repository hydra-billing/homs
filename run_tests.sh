#! /bin/bash

RAILS_ENV=test
NODE_ENV=test

/wait_for_postgres.sh

# prepare configs
cp config/bpm.yml.sample config/bpm.yml
cp config/database.yml.sample config/database.yml
cp config/secrets.yml.sample config/secrets.yml
echo "sources:
  bpmanagementsystem:
    type: 'static/bpm'
" > config/sources.yml

echo "  adapter: camunda" >> config/hbw.yml

bundle exec rake db:migrate && bundle exec rake db:seed

# add source billing for tests
echo "sources:
  bpmanagementsystem:
    type: 'static/bpm'
  billing:
    type: sql/oracle
    tns_name: test
    username: test
    password: test
" > config/sources.yml

bundle exec rspec ./spec --format RspecJunitFormatter --out test-reports/out.xml --format progress
rubocop --require rubocop/formatter/junit_formatter --format RuboCop::Formatter::JUnitFormatter --out test-reports/rubocop.xml

if [ "$GENERATE_DOC" = 'true' ]; then bundle exec rake docs:generate && zip -r doc.zip public/doc; fi
