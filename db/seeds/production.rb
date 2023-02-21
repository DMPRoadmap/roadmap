#!/usr/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true
# warn_indent: true

########## For sandbox only
# Steps:
# 1) change default database to production database, then run `rails export:build_sandbox_data` to generate production-related data
# 2) switch database to the sandbox database
# 3) run rake db:seed or created alongside the db with db:setup to seed data
##########
# Forcing load seed file in sequence by last number
# seeds_1 to seeds_3 are rake-generated. Other seeds file are manually edited
########## Uncomment following if we need to redo sandbox data injection
# puts 'run seeds.rb file now...'
# Dir[File.join(Rails.root, 'db', 'seeds', 'sandbox', '*.rb')].sort.each_with_index do |seed, index|
#     if seed.include? index.to_s
#         load seed
#     end
# end


######## For 3.1.0 Migration only
Rake::Task['before_seeds:copy_data'].invoke
Dir[File.join(Rails.root, 'db', 'seeds', 'staging', '*.rb')].sort.each_with_index do |seed, index|
    puts 'run staging/seeds_' + index.to_s + '.rb now..'
    load seed
end
Rake::Task['rewrite_postgres:retrieve_data'].invoke