#!/usr/bin/env ruby

require 'aws-sdk-ssm'
require 'fileutils'

include FileUtils

# path to your application root.
APP_ROOT = File.expand_path('..', __dir__)

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

chdir "#{APP_ROOT}/application" do

  puts "You are here: #{APP_ROOT}/application"
  puts "Here contains: #{Dir.children("#{APP_ROOT}/application").join(', ')}"

  prefix = "RAILS_ENV=#{ENV['RAILS_ENV']}"
  system! "bin/rails db:environment:set RAILS_ENV=#{ENV['RAILS_ENV']}"

  # Fetch the Rails credentials from SSM
  master_key = File.open(Rails.root.join('config', 'master.key'), 'w+')
  key = "/uc3/dmp/tool/#{ARGV[0]}/RailsMasterKey"
  master_key.write(ssm.get_parameter(name: key, with_decryption: true)&.parameter&.value)
  master_key.close

  credentials_enc = File.open(Rails.root.join('config', 'credentials.yaml.enc'), 'w+')
  key = "/uc3/dmp/tool/#{ARGV[0]}/RailsCredentials"
  credentials_enc.write(ssm.get_parameter(name: key, with_decryption: true)&.parameter&.value)
  credentials_enc.close

  # Fetch the DB credentials from SSM
  key = "/uc3/dmp/tool/#{ARGV[0]}/RdsDbaUsername"
  system! "export DB_USERNAME=#{ssm.get_parameter(name: key, with_decryption: true)&.parameter&.value}"
  key = "/uc3/dmp/tool/#{ARGV[0]}/RdsDbaPassword"
  system! "export DB_PASSWORD=#{ssm.get_parameter(name: key, with_decryption: true)&.parameter&.value}"

  # Temporary call to seed the DB from a mysqldump file
  # file = ''
  # system! "mysql #{ENV['DB_NAME']} -h #{ENV['DB_HOST']} -u #{ENV['DB_USERNAME']} -p #{ENV['DB_PASSWORD']} < #{file}"

  system! "export WICKED_PDF_PATH=`which wkhtmltopdf`"

  system! "#{prefix} bin/rails db:migrate"

  system! "#{prefix} bin/rails assets:clobber"
  system! "#{prefix} bin/rails assets:precompile"

  system! "#{prefix} bin/puma -C config/puma.rb -p 80"
end
