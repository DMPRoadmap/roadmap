require File.expand_path('../boot', __FILE__)

require 'rails/all'
#require 'devise'
require 'recaptcha/rails'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
#if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  #Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
#end
#Bundler.require(:default, Rails.env)
#Changed when migrated to rails 4.0.0
Bundler.require(*Rails.groups)

module DMPRoadmap
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
	
	#commented 15.03.2016
	#config.autoload_paths << Rails.root.join('lib')

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
	
	# Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    #config.active_record.whitelist_attributes = true	
	
	# Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    config.assets.precompile += %w(plans.js)
    config.assets.precompile += %w(projects.js)    
    config.assets.precompile += %w(jquery.placeholder.js)
    config.assets.precompile += %w(jquery.tablesorter.js)
    config.assets.precompile += %w(export_configure.js)
    config.assets.precompile += %w(toolbar.js)
    config.assets.precompile += %w(admin.js)
    config.assets.precompile += %w(admin.css)
    config.assets.precompile += %w(bootstrap_and_overrides.css)
    
    config.autoload_paths += %W(#{config.root}/lib)
    config.action_controller.include_all_helpers = true

    # Set the default host for mailer URLs
    config.action_mailer.default_url_options = { :host => 'example@dcc.ac.uk' }
	

    # Enable shibboleth as an alternative authentication method
    # Requires server configuration and omniauth shibboleth provider configuration
    # See config/initializers/omniauth.rb
    config.shibboleth_enabled = false

    # Absolute path to Shibboleth SSO Login
    #config.shibboleth_login = 'https://localhost/Shibboleth.sso/Login'

    WickedPdf.config = {
	    :exe_path => '/usr/local/bin/wkhtmltopdf'
	  }
    
    # Active Record will no longer suppress errors raised in after_rollback or after_commit
    # in the next version. Devise appears to be using those callbacks.
    # To accept the new behaviour use 'true' otherwise use 'false'
    config.active_record.raise_in_transactional_callbacks = true
  end
end
