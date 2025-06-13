# frozen_string_literal: true

require 'recaptcha/rails'

# the keys are set in config/credentials.yml.env

Recaptcha.configure do |config|
  config.site_key = ENV["RECAPTCHA_SITE_KEY"]
  config.secret_key = ENV["RECAPTCHA_SECRET_KEY"]
  config.proxy = 'http://someproxy.com:port'
end
