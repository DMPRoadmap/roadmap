#!/usr/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true
# warn_indent: true

########## This file serves for the sandbox testing after 3.0 release
# Steps:
# 1) change default database to production database, then run `rails export:build_sandbox_data` to generate production-related data
# 2) switch database to the sandbox database
# 3) run rake db:seed or created alongside the db with db:setup to seed data
##########

# Forcing load seed file in sequence by last number
# seeds_1 to seeds_3 are rake-generated. Other seeds file are manually edited
puts 'run seeds.rb file now...'
Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each_with_index do |seed, index|
  if seed.include? index.to_s
    load seed
  end
end