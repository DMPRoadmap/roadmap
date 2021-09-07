# frozen_string_literal: true

require 'rails/all'
require 'recaptcha/rails'
require 'csv'
require 'nulldb/rails'
require_relative "boot"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DMPRoadmap

  class Application < Rails::Application

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # --------------------------------- #
    # OVERRIDES TO DEFAULT RAILS CONFIG #
    # --------------------------------- #

    config.autoload_paths += %W[#{config.root}/lib]

    # HTML tags that are allowed to pass through `sanitize`.
    config.action_view.sanitized_allowed_tags = %w[
      p br strong em a table thead tbody tr td th tfoot caption ul ol li
    ]

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Allow controllers to access view helpers
    # TODO: We should see what methods specifically are used by the controllers
    #       and include them specifically in the controllers. We should also consider
    #       moving our helper methods into Presenters if it makes sense
    config.action_controller.include_all_helpers = true

    # Set the default host for mailer URLs
    config.action_mailer.default_url_options = { :host => Rails.application.secrets.mailer_default_host }

    # Enable shibboleth as an alternative authentication method
    # Requires server configuration and omniauth shibboleth provider configuration
    # See config/initializers/devise.rb
    config.shibboleth_enabled = false

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
    # config.active_record.raise_in_transactional_callbacks = true

    # Load Branded terminology (e.g. organization name, application name, etc.)
    if File.exists?(Rails.root.join('config/branding.yml'))
      config.branding = config_for(:branding).deep_symbolize_keys
    end

    # The default visibility setting for new plans
    #   organisationally_visible  - Any member of the user's org can view, export and duplicate the plan
    #   publicly_visibile         - (NOT advisable because plans will show up in Public DMPs page by default)
    #   is_test                   - (NOT advisable because test plans are excluded from statistics)
    #   privately_visible         - Only the owner and people they invite can access the plan
    config.default_plan_visibility = 'privately_visible'

    # The percentage of answered questions needed to enable the plan visibility section of the Share plan page
    config.default_plan_percentage_answered = 0

    # This is the protocol that will be used on method 'direct_link' defined in template_helper.rb.
    # This configuration is required since the current (2021-08-09) production deployment does not
    # pass the correct protocol from the reverse proxy (HAProxy) to the back end web servers.
    # The value can be either 'http' or 'https'
    # TODO: Change production server configuration so that we can ignore this configuration.
    config.direct_link_protocol = 'https'

    # DMP Assistant works with the assumption that the user will not use a
    # specific funder. The view for choosing a funder when creating a plan
    # removed the option for selecting a funder. A funder is needed to show the
    # customized templates. For this reason we are specifying in the
    # documentation the funder that 
    config.default_funder_name = Rails.application.secrets.default_funder_name
  end

end
