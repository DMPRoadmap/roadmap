#!/bin/bash
set -e

bundle check || bundle update

bundle exec rake assets:precompile

rm log/development.log

touch log/development.log

bundle exec puma -C config/puma.rb
