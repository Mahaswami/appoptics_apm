#!/bin/bash

# used by run_tests_docker.sh
# call with:
# docker-compose run --service-ports ruby_appoptics_apm /code/ruby-appoptics_apm/ruby_setup.sh <ruby-version> <gemfile> <DBNAME=mysql2> <true|false>
# docker-compose run --service-ports ruby_appoptics_apm /code/ruby-appoptics_apm/ruby_setup.sh 2.4.1 gemfiles/libraries.gemfile

cd /code/ruby-appoptics_apm/

rbenv global $1

rm gemfiles/*.lock

export RVM_TEST=$1
export BUNDLE_GEMFILE=$2
bundle install

bundle update
bundle exec rake fetch_ext_deps
bundle exec rake clean
bundle exec rake compile

# start postgres
service postgresql start

# start redis
service redis-server start

# start memcached
service memcached start

# mysql add table for tests
mysql -e 'create database travis_ci_test;' -h$MYSQL_HOST -p$MYSQL_ROOT_PASSWORD

# replicate stdout of tests to file in local log directory
export TEST_RUNS_TO_FILE=true
export $3

if [ "$4" == "true" ]; then
  /bin/bash
  # now run tests either with:
  # bundle exec rake test TEST=test/instrumentation/curb_test.rb
  # or
  # bundle exec ruby -I test test/instrumentation/curb_test.rb -n test_obey_collect_backtraces_when_false
else
  bundle exec rake test
fi

mysql -e 'drop database travis_ci_test;' -h$MYSQL_HOST -p$MYSQL_ROOT_PASSWORD
