# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Question: is there a nicer way to do this require_relative?
require_relative '../lib/ssm_config_loader'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load master_key into ENV
if ENV.key?('SSM_ROOT_PATH')
  # Ensure our custom config loader ssm_parameter_store is inserted into Anyway.loaders
  # prior to instantiating our custom Anyway::Config classes.
  Anyway.loaders.insert_before(:env, :ssm_parameter_store, SsmConfigLoader)

  begin
    ssm = Uc3Ssm::ConfigResolver.new
    master_key = ssm.parameter_for_key('master_key')
    ENV['RAILS_MASTER_KEY'] = master_key.chomp if master_key.present?
  rescue StandardError => e
    ActiveSupport::Logger.new($stdout).warn("Could not retrieve master_key from SSM Parameter Store: #{e.full_message}")
  end
end

module DMPRoadmap
  # The DMPRoadmap Rails application
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # --------------------------------#
    # OVERRIDES TO DEFAULT RAILS CONFIG #
    # --------------------------------#
    # Ensure that Zeitwerk knows to load our classes in the lib directory
    config.eager_load_paths << config.root.join('lib')

    # CVE-2022-32224: add some compatibility with YAML.safe_load
    # Rails 5,6,7 are using YAML.safe_load as the default YAML deserializer
    config.active_record.yaml_column_permitted_classes = [ActiveSupport::HashWithIndifferentAccess, Symbol, Date, Time]

    # Have Zeitwerk skip generators because the generator templates are
    # incompatible with the Rails module/class naming conventions
    Rails.autoloaders.main.ignore(config.root.join('lib/generators'))

    # HTML tags that are allowed to pass through `sanitize`.
    config.action_view.sanitized_allowed_tags = %w[
      p br strong em a table thead tbody tr td th tfoot caption ul ol li span
    ]
    config.action_view.sanitized_allowed_attributes = %w[style]

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Allow controllers to access view helpers
    # TODO: We should see what methods specifically are used by the controllers
    #       and include them specifically in the controllers. We should also consider
    #       moving our helper methods into Presenters if it makes sense
    config.action_controller.include_all_helpers = true

    # Load AnywayConfig class, but not if running `rails credentials:edit`
    config.x.dmproadmap = DmproadmapConfig.new unless defined?(::Rails::Command::CredentialsCommand)

    # Set the default host for mailer URLs
    config.action_mailer.default_url_options = { host: config.x.dmproadmap.server_host }
  end
end
