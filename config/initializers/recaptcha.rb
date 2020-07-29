# frozen_string_literal: true

require "recaptcha/rails"

# the keys are set in config/credentials.yml.env

Recaptcha.configure do |config|
  config.site_key = Rails.application.credentials.recaptcha[:site_key]
  config.secret_key = Rails.application.credentials.recaptcha[:secret_key]
  config.proxy = "http://someproxy.com:port"
end
