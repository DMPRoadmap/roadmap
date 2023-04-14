# Load the Rails application.
require_relative "application"

Rails.application.configure do
  # Disable serving static files from the `/public` folder by default since Apache or NGINX already handles this.
  config.public_file_server.enabled = Rails.configuration.x.dmproadmap.rails_serve_static_files.present?

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')
  if Rails.configuration.x.dmproadmap.rails_log_to_stdout.present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
end

# Used by Rails' routes url_helpers (typically when including a link in an email)
Rails.application.routes.default_url_options[:host] = Rails.configuration.x.dmproadmap.server_host

# Initialize the Rails application.
Rails.application.initialize!
