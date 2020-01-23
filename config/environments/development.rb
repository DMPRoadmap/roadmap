Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's
  # package.json
  config.webpacker.check_yarn_integrity = false

  # Settings specified here will take precedence over those in config/application.rb.
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  if File.exist?(Rails.root.join('tmp', 'caching-dev.txt'))
    config.action_controller.perform_caching = true
  else
    config.action_controller.perform_caching = false
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.log_level = :debug

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.action_mailer.perform_deliveries = false

  BetterErrors::Middleware.allow_ip! "10.0.2.2" if defined?(BetterErrors)

  config.after_initialize do
    ActiveRecord::Base.logger = Rails.logger.clone
    ActiveRecord::Base.logger.level = Logger::INFO
    ActiveRecord::Base.logger.level = Logger::DEBUG
  end

end

Rails.application.routes.default_url_options[:host] = "dmproadmap.org"

