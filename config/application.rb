require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'recaptcha/rails'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

begin
  # If Rollbar has been included in the Bundle, load it here.
  require "rollbar"
rescue LoadError => e
  # noop
end

module DMPRoadmap
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    #   See: https://apidock.com/rails/v5.2.3/Rails/Application/Configuration/load_defaults
    # config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Returning `false` from a Model callback used to halt the entire callback
    # chain. This pattern has been deprecated and returning `false` will no longer
    # halt the entire chain. In later versions of Rails we will need to `throw(:abort)`
    # to halt the chain.
    # TODO: Leaving this enabled for now for backward compatibility. It will
    #       throw deprecation warnings until we clean it up
    ActiveSupport.halt_callback_chains_on_return_false = true

    # Autoloading is now disabled after booting in the production environment by default.
    # Eager loading the application is part of the boot process, so top-level constants
    # are fine and are still autoloaded, no need to require their files.
    # Constants in deeper places only executed at runtime, like regular method bodies,
    # are also fine because the file defining them will have been eager loaded while booting.
    #
    # TODO: For the vast majority of applications this change needs no action. But
    #       in the very rare event that your application needs autoloading while running
    #       in production mode, set this value to `true`
    config.enable_dependency_loading = false

    # TODO: Setting this to false for now so that our form submissions remain the same
    action_view.form_with_generates_remote_forms = false

    # The following are carried over from Rails 4.2 version of DMPRoadmap
    # TODO: Determine if these are still necessary
    # ------------------------------------------------------------

    # HTML tags that are allowed to pass through `sanitize`.
    config.action_view.sanitized_allowed_tags = %w[
      p br strong em a table thead tbody tr td th tfoot caption ul ol li
    ]

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

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

    # Load Branded terminology (e.g. organization name, application name, etc.)
    # TODO: Consider moving the branding stuff to an initializer like the pattern
    #       used in the initializers/external_apis/*.rb
    if File.exists?(Rails.root.join('config', 'branding.yml'))
      config.branding = config_for(:branding).deep_symbolize_keys
    end

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
