# frozen_string_literal: true

require 'bundler/setup'
require 'fileutils'
require 'uc3-ssm'

include FileUtils

# path to your application root.
APP_ROOT = File.expand_path('..', __dir__)

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

PROJECT_ROOT="#{APP_ROOT}/application"

chdir PROJECT_ROOT do

puts "Checking ENV:"
pp ENV

  # Run any outstanding DB migrations
  system! 'rails db:migrate'

  # Rebuild the assets
  system! 'rails assets:clobber'
  system! 'rails assets:precompile'

  # If an upgrade script was provided, run it.
  if File.exists? 'upgrade.sh'
    File.open('upgrade.sh', 'r').each_line { |line| system! line }
  end

  # Temporary call to seed the DB from a mysqldump file
  # file = ''
  # system! "mysql #{ENV['DB_NAME']} -h #{ENV['DB_HOST']} -u #{ENV['DB_USERNAME']} -p #{ENV['DB_PASSWORD']} < #{file}"

  system! "#{prefix} bin/puma -C config/puma.rb -p 80"
end
