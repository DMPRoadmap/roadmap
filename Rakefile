#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'rake/testtask'
require File.expand_path('../config/application', __FILE__)

DMPRoadmap::Application.load_tasks

# TODO: destroy rdoc rake task once finished with new documentation

RDoc::Task.new :rdoc do |rdoc|
  rdoc.main = "README.rdoc"

  rdoc.rdoc_files.include("README.rdoc", "doc/*.rdoc", "app/**/*.rb", "lib/*.rb", "config/**/*.rb")
  #change above to fit needs

  rdoc.title = "DMPRoadmap Documentation"
  rdoc.options << "--all" 
end

task default: :test
