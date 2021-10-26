# frozen_string_literal: true

require_relative "boot"

require "rails/all"

require "csv"

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
    config.action_mailer.default_url_options = { host: Socket.gethostname.to_s }

  end

end
