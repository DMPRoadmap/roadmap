Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

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

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  config.action_mailer.perform_deliveries = false

  BetterErrors::Midleware.allow_ip! "10.0.2.2" if defined?(BetterErrors) && Rails.env == :development

  config.after_initialize do
    ActiveRecord::Base.logger = Rails.logger.clone
    ActiveRecord::Base.logger.level = Logger::INFO
    ActiveRecord::Base.logger.level = Logger::DEBUG
  end
  # Assets pipeline
  config.assets.enabled = false
  config.assets.debug = false
  config.assets.compile = false
  config.assets.quiet = true

# START DMPTool customization  
# ----------------------------------------
  # Whether or not to use Webpack's fingerprinted assets (code in application_helper.rb)  
  config.use_fingerprinted_assets = false
# ----------------------------------------
# END DMPTool customization
  
end
