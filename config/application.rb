require File.expand_path('../boot', __FILE__)

require 'rails/all'
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

begin
  # If Rollbar has been included in the Bundle, load it here.
  require "rollbar"
rescue LoadError => e
  # noop
end

module DMPRoadmap
  class Application < Rails::Application

    # HTML tags that are allowed to pass through `sanitize`.
    config.action_view.sanitized_allowed_tags = %w[
      p br strong em a table thead tbody tr td th tfoot caption ul ol li
    ]

    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
      g.test_framework  :rspec
      g.javascripts false
      g.stylesheets false
      g.skip_routes true
      g.view_specs false
      g.helper_specs false
      g.controller_specs false
    end

    # TODO: Set up a better Rails cache, preferrably Redis
    #
    # From Rails docs:
    # https://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-memorystore
    #
    # If you're running multiple Ruby on Rails server processes (which is the case if
    # you're using Phusion Passenger or puma clustered mode), then your Rails server
    # process instances won't be able to share cache data with each other. This cache
    # store is not appropriate for large application deployments. However, it can work
    # well for small, low traffic sites with only a couple of server processes, as well
    # as development and test environments.
    config.cache_store = :memory_store, { size: 32.megabytes }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

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

    config.eager_load_paths << "app/presenters"

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    #config.active_record.whitelist_attributes = true

    config.autoload_paths += %W(#{config.root}/lib)
    config.action_controller.include_all_helpers = true

    # Set the default host for mailer URLs
    config.action_mailer.default_url_options = { :host => "#{Socket.gethostname}" }

    # Enable shibboleth as an alternative authentication method
    # Requires server configuration and omniauth shibboleth provider configuration
    # See config/initializers/devise.rb
    config.shibboleth_enabled = true

    # Relative path to Shibboleth SSO Logout
    config.shibboleth_login = '/Shibboleth.sso/Login'
    config.shibboleth_logout_url = '/Shibboleth.sso/Logout?return='

    # If this value is set to true your users will be presented with a list of orgs that have a
    # shibboleth identifier in the orgs_identifiers table. If it is set to false (default), the user
    # will be driven out to your federation's discovery service
    #
    # A super admin will also be able to associate orgs with their shibboleth entityIds if this is set to true
    config.shibboleth_use_filtered_discovery_service = false

    # Active Record will no longer suppress errors raised in after_rollback or after_commit
    # in the next version. Devise appears to be using those callbacks.
    # To accept the new behaviour use 'true' otherwise use 'false'
    config.active_record.raise_in_transactional_callbacks = true

    # Load Branded terminology (e.g. organization name, application name, etc.)
    if File.exists?(Rails.root.join('config', 'branding.yml'))
      config.branding = config_for(:branding).deep_symbolize_keys
    end

    # org abbreviation for the root google analytics tracker that gets planted on every page
    # config.x.tracker_root = "DMPRoadmap"

    # The default visibility setting for new plans
    #   organisationally_visible  - Any member of the user's org can view, export and duplicate the plan
    #   publicly_visibile         - (NOT advisable because plans will show up in Public DMPs page by default)
    #   is_test                   - (NOT advisable because test plans are excluded from statistics)
    #   privately_visible         - Only the owner and people they invite can access the plan
    config.default_plan_visibility = 'privately_visible'

    # The percentage of answered questions needed to enable the plan visibility section of the Share plan page
    config.default_plan_percentage_answered = 50
  end
end
