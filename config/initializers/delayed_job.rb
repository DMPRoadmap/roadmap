# frozen_string_literal: true

# Delayed Job initializer to help determine why it's not connecting to the DB
Delayed::Job.class_eval do
  puts "DB Configuration:"
  pp ActiveRecord::Base.connection_db_config
end