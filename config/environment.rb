# Load the Rails application.
require File.expand_path('../application', __FILE__)

#init a debugger
Rails.logger = Logger.new(STDOUT)

# Initialize the Rails application.
Rails.application.initialize!