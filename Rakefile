#!/usr/bin/env rake
# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
# require 'rake/testtask'
# require File.expand_path('../config/application', __FILE__)

# DMPRoadmap::Application.load_tasks

# task default: :test

require_relative "config/application"

# Resque setup for ActiveJob
# require 'resque'
# require 'resque/tasks'
# require 'your/app'

DMPRoadmap::Application.load_tasks

task default: :test
