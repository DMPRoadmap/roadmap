#!/usr/bin/env ruby

require 'fileutils'

include FileUtils

# path to your application root.
APP_ROOT = File.expand_path('..', __dir__)

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

chdir "#{APP_ROOT}/roadmap" do
  prefix = "RAILS_ENV=#{ENV['RAILS_ENV']}"
  system! "bin/rails db:environment:set RAILS_ENV=#{ENV['RAILS_ENV']}"

  # Temporary call to seed the DB from a mysqldump file
  # file = ''
  # system! "mysql #{ENV['DB_NAME']} -h #{ENV['DB_HOST']} -u #{ENV['DB_USERNAME']} -p #{ENV['DB_PASSWORD']} < #{file}"

  system! "export WICKED_PDF_PATH=`which wkhtmltopdf`"

  system! "#{prefix} bin/rails db:migrate"

  system! "#{prefix} bin/rails assets:precompile"

  system! "#{prefix} bin/puma -C config/puma.rb -p 80"
end
