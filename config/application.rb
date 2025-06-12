# frozen_string_literal: true

require_relative "boot"

require "rails/all"

require "csv"

Bundler.require(*Rails.groups)

module DMPRoadmap

  class Application < Rails::Application

    config.x.app_version = "2025.11" 

    config.load_defaults 5.2

    hosts = ENV.fetch('DMPROADMAP_HOSTS').split(',')
    
    config.hosts.each { |host| Rails.application.config.hosts << host }

    config.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log", "daily")

    config.autoload_paths += %W[#{config.root}/lib]

    config.action_view.sanitized_allowed_tags = %w[
      p br strong em a table thead tbody tr td th tfoot caption ul ol li
    ]

    config.filter_parameters += [:password]

    config.active_support.escape_html_entities_in_json = true

    config.action_controller.include_all_helpers = true

    config.action_mailer.default_url_options = { host: ENV["HOST_URL"] }

    Rails.application.config.assets.configure do |env|
      env.export_concurrent = false
    end

    # --------------------- #
    # ORGANISATION SETTINGS #
    # --------------------- #

    config.x.organisation.name = ENV['ORGANISATION_NAME']

    config.x.organisation.abbreviation = ENV['ORGANISATION_ABBREVIATION']

    config.x.organisation.url = ENV['ORGANISATION_URL']

    config.x.organisation.copywrite_name = ENV['ORGANISATION_COPYWRITE_NAME']

    config.x.organisation.email = ENV['ORGANISATION_EMAIL']

    config.x.organisation.do_not_reply_email = ENV['ORGANISATION_DO_NOT_REPLY_EMAIL']

    config.x.organisation.helpdesk_email = ENV['ORGANISATION_HELPDESK_EMAIL']

    config.x.organisation.telephone = ENV['ORGANISATION_TELEPHONE']

    # rubocop:disable Naming/VariableNumber
    config.x.organisation.address = {
      line_1: ENV['ORGANISATION_ADDRESS_LINE_1'],
      line_2: ENV['ORGANISATION_ADDRESS_LINE_2'],
      line_3: ENV['ORGANISATION_ADDRESS_LINE_3'],
      line_4: ENV['ORGANISATION_ADDRESS_LINE_4'],
      country: ENV['ORGANISATION_ADDRESS_COUNTRY']
    }
    # rubocop:enable Naming/VariableNumber

    config.x.organisation.google_maps_link = ENV['ORGANISATION_GOOGLE_MAPS_LINK']

    # -------------------- #
    # APPLICATION SETTINGS #
    # -------------------- #

    config.x.application.name = ENV['APPLICATION_NAME']

    config.x.application.archived_accounts_email_suffix = ENV['APPLICATION_ARCHIVED_ACCOUNTS_EMAIL_SUFFIX']

    config.x.application.csv_separators = [',', '|', '#']

    config.x.application.api_max_page_size = ENV['APPLICATION_API_MAX_PAGE_SIZE']

    config.x.application.api_documentation_urls = {
      v0: ENV['APPLICATION_API_DOCUMENTATION_URLS_VO'],
      v1: ENV['APPLICATION_API_DOCUMENTATION_URLS_V1']
    }

    config.x.application.welcome_links = [
      {
        title: ENV['APPLICATION_WELCOME_LINK_TITLE_1'],
        url: ENV['APPLICATION_WELCOME_LINK_URL_1']
      }, {
        title: ENV['APPLICATION_WELCOME_LINK_TITLE_2'],
        url: ENV['APPLICATION_WELCOME_LINK_URL_2']
      }, {
        title: ENV['APPLICATION_WELCOME_LINK_TITLE_3'],
        url: ENV['APPLICATION_WELCOME_LINK_URL_3']
      }, {
        title: ENV['APPLICATION_WELCOME_LINK_TITLE_4'],
        url: ENV['APPLICATION_WELCOME_LINK_URL_4']
      }, {
        title: ENV['APPLICATION_WELCOME_LINK_TITLE_5'],
        url: ENV['APPLICATION_WELCOME_LINK_URL_5']
      }
    ]
    # The default user email preferences used when a new account is created
    config.x.application.preferences = {
      email: {
        users: {
          new_comment: ENV['APPLICATION_PREFERENCES_NEW_COMMENT'],
          admin_privileges: ENV['APPLICATION_PREFERENCES_ADMIN_PRIVILEGES'],
          added_as_coowner: ENV['APPLICATION_PREFERENCES_ADDED_AS_COOWNER'],
          feedback_requested: ENV['APPLICATION_PREFERENCES_FEEDBACK_REQUESTED'],
          feedback_provided: ENV['APPLICATION_PREFERENCES_FEEDBACK_PROVIDED']
        },
        owners_and_coowners: {
          visibility_changed: ENV['APPLICATION_PREFERENCES_VISIBILITY_CHANGED']
        }
      }
    }
    # only take orgs from local and not allow on-the-fly creation
    config.x.application.restrict_orgs = ENV['APPLICATION_RESTRICT_ORGS']

    config.x.application.display_contributor_phone_number = ENV['APPLICATION_DISPLAY_CONTRIBUTOR_PHONE_NUMBER']

    config.x.application.require_contributor_name = ENV['APPLICATION_REQUIRE_CONTRIBUTOR_NAME']

    config.x.application.require_contributor_email = ENV['APPLICATION_REQUIRE_CONTRIBUTOR_EMAIL']

    config.x.application.guidance_comments_toggleable = ENV['APPLICATION_GUIDANCE_COMMENTS_TOGGLEABLE']

    config.x.application.guidance_comments_opened_by_default = ENV['APPLICATION_GUIDANCE_COMMENTS_OPENED_BY_DEFAULT']

    # ------------------- #
    # SHIBBOLETH SETTINGS #
    # ------------------- #

    config.x.shibboleth.enabled = true

    config.x.shibboleth.login_url = '/Shibboleth.sso/Login'

    config.x.shibboleth.logout_url = '/Shibboleth.sso/Logout?return='

    # If this value is set to true your users will be presented with a list of orgs that have a
    # shibboleth identifier in the orgs_identifiers table (and a super admin will also be able 
    # to associate orgs with their shibboleth entityIds). If it is set to false (default), the user
    # will be driven out to your federation's discovery service
    config.x.shibboleth.use_filtered_discovery_service = false

    # ------- #
    # LOCALES #
    # ------- #

    # The default locale (use the i18n format!)
    config.x.locales.default = 'en-GB'
    # The character that separates a locale's ISO code for i18n. (e.g. `en-GB` or `en`)
    # Changing this value is not recommended!
    config.x.locales.i18n_join_character = '-'
    # The character that separates a locale's ISO code for Gettext. (e.g. `en_GB` or `en`)
    # Changing this value is not recommended!
    config.x.locales.gettext_join_character = '_'

    # ---------- #
    # THRESHOLDS #
    # ---------- #

    # Determines the number of links a funder is allowed to add to their template
    config.x.max_number_links_funder = 5
    # Determines the number of links a funder can add for sample plans for their template
    config.x.max_number_links_sample_plan = 5
    # Determines the maximum number of themes to display per column when an org admin
    # updates a template question or guidance
    config.x.max_number_themes_per_column = 5
    # default results per page
    config.x.results_per_page = 10

    # ------------- #
    # PLAN DEFAULTS #
    # ------------- #

    # The default visibility a plan receives when it is created.
    # options: 'privately_visible', 'organisationally_visible' and 'publicly_visibile'
    config.x.plans.default_visibility = 'privately_visible'

    # The percentage of answers that have been filled out that determine if a plan
    # will be marked as complete. Plan completion has implications on whether or
    # not plan visibility settings are editable by the user and whether or not the
    # plan can be submitted for feedback
    config.x.plans.default_percentage_answered = 50

    # Whether or not Organisational administrators can read all of the user's plans
    # regardless of the plans visibility and whether or not the plan has been shared
    config.x.plans.org_admins_read_all = true

    # Whether or not super admins can read all of the user's plans regardless of
    # the plans visibility and whether or not the plan has been shared
    config.x.plans.super_admins_read_all = true

    # Check download of a plan coversheet tickbox
    config.x.plans.download_coversheet_tickbox_checked = false

    # ---------------------------------------------------- #
    # CACHING - all values are in seconds (86400 == 1 Day) #
    # ---------------------------------------------------- #

    # Determines how long to cache results for OrgSelection::SearchService
    config.x.cache.org_selection_expiration = 86_400
    # Determines how long to cache results for the ResearchProjectsController
    config.x.cache.research_projects_expiration = 86_400

    # ---------------- #
    # Google Analytics #
    # ---------------- #
    # this is the abbreviation for the installation's root org as set in the org table
    config.x.google_analytics.tracker_root = ''

    # --------- #
    # reCAPTCHA #
    # --------- #
    config.x.recaptcha.enabled = false

    # --------------------------------------------------- #
    # Machine Actionable / Networked DMP Features (maDMP) #
    # --------------------------------------------------- #
    # Enable/disable functionality on the Project Details tab
    config.x.madmp.enable_ethical_issues = true

    config.x.madmp.enable_research_domain = true

    # This flag will enable/disable the entire Research Outputs tab. The others below will
    # just enable/disable specific functionality on the Research Outputs tab
    config.x.madmp.enable_research_outputs = true

    config.x.madmp.enable_license_selection = true

    config.x.madmp.enable_metadata_standard_selection = true

    config.x.madmp.enable_repository_selection = true

    # The following flags will allow the system to include the question and answer in the JSON output
    #   - questions with a theme equal to 'Preservation'
    config.x.madmp.extract_preservation_statements_from_themed_questions = false

    #   - questions with a theme equal to 'Data Collection'
    config.x.madmp.extract_data_quality_statements_from_themed_questions = false

    #   - questions with a theme equal to 'Ethics & privacy' or 'Storage & security'
    config.x.madmp.extract_security_privacy_statements_from_themed_questions = false

    # Specify a list of the preferred licenses types. These licenses will appear in a select
    # box on the 'Research Outputs' tab when editing a plan along with the option to select
    # 'other'. When 'other' is selected, the user is presented with the full list of licenses.
    #
    # The licenses will appear in the order you specify here.
    #
    # Note that the values you enter must match the :identifier field of the licenses table.
    # You can use the `%{latest}` markup in place of version numbers if desired.
    config.x.madmp.preferred_licenses = [
      'CC-BY-%{latest}',
      'CC-BY-SA-%{latest}',
      'CC-BY-NC-%{latest}',
      'CC-BY-NC-SA-%{latest}',
      'CC-BY-ND-%{latest}',
      'CC-BY-NC-ND-%{latest}',
      'CC0-%{latest}'
    ]

    # Link to external guidance about selecting one of the preferred licenses. A default
    # URL will be displayed if none is provided here. See app/views/research_outputs/licenses/_form
    config.x.madmp.preferred_licenses_guidance_url = 'https://creativecommons.org/about/cclicenses/'


    # don adding environment variables from ./config/environments/* files
    config.cache_classes = ENV["CACHE_CLASSES"]

    config.eager_load = ENV["EAGER_LOAD"]

    config.consider_all_requests_local = ENV["CONSIDER_ALL_REQUESTS_LOCAL"]

    config.action_controller.perform_caching = ENV["PERFORM_CACHING"]

    config.cache_store = ENV["CACHE_STORE"].to_sym

    config.active_storage.service = ENV["ACTIVE_STORAGE_SERVICE"].to_sym

    config.action_mailer.raise_delivery_errors = ENV["ACTION_MAILER_RAISE_DELIVERY_ERRORS"]

    config.action_mailer.delivery_method = ENV["ACTION_MAILER_DELIVERY_METHOD"].to_sym

    config.action_mailer.smtp_settings = { 
      address: ENV["ACTION_MAILER_SMTP_SETTINGS_ADDRESS"], 
      port: ENV["ACTION_MAILER_SMTP_SETTINGS_PORT"] 
    }

    config.log_level = ENV["LOG_LEVEL"]

    config.active_support.disallowed_deprecation = ENV["ACTIVE_SUPPORT_DISALLOWED_DEPRECATION"].to_sym

    config.active_support.disallowed_deprecation_warnings = JSON.parse(ENV["ACTIVE_SUPPORT_DISALLOWED_DEPRECATION_WARNINGS"])

    config.active_record.migration_error = ENV["ACTIVE_RECORD_MIGRATION_ERROR"].to_sym

    config.active_record.verbose_query_logs = ENV["ACTIVE_RECORD_VERBOSE_QUERY_LOGS"]

    config.assets.debug = ENV["ASSETS_DEBUG"]

    config.assets.quiet = ENV["ASSETS_QUIET"]

    config.file_watcher = ENV["FILE_WATCHER"] != "" ? ENV["FILE_WATCHER"].constantize : nil

    config.routes.default_url_options[:host] = JSON.parse(ENV["DMPROADMAP_HOSTS"]).first

    config.action_view.cache_template_loading = ENV["ACTION_VIEW_CACHE_TEMPLATE_LOADING"]

    config.public_file_server.enabled = ENV["PUBLIC_FILE_SERVER_ENABLED"]

    config.public_file_server.headers = {
      "Cache-Control" => [
        "public",
        "max-age=#{ENV["PUBLIC_FILE_SERVER_CACHE_SECONDS"]}",
        ENV["PUBLIC_FILE_SERVER_CACHE_EXTRA"].presence
      ].compact.join(", ")
    }

    config.action_dispatch.show_exceptions = ENV["ACTION_DISPACTH_SHOW_EXCEPTIONS"]

    config.action_controller.allow_forgery_protection = ENV["ACTION_CONTROLLER_ALLOW_FORGERY_PROTECTION"]

    config.action_mailer.perform_caching = ENV["ACTION_MAILER_PERFORM_CACHING"]

    config.active_support.deprecation = ENV["ACTIVE_SUPPORT_DEPRECATION"].to_sym

    config.i18n.enforce_available_locales = ENV["I18N_ENFORCE_AVAILABLE_LOCALES"]

    config.require_master_key = ENV["REQUIRE_MASTER_KEY"]

    config.assets.compile = ENV["ASSETS_COMPILE"]

    config.log_tags = ENV["LOG_TAGS"]

    config.i18n.fallbacks = ENV["I18N_FALLBACKS"]

    config.log_formatter = Logger::Formatter.new

    if ENV['RAILS_LOG_TO_STDOUT'] == "true"
      logger = ActiveSupport::Logger.new($stdout)
      logger.formatter = config.log_formatter
      config.logger = ActiveSupport::TaggedLogging.new(logger)
    end

    config.active_record.dump_schema_after_migration = ENV["ACTIVE_RECORD_DUMP_SCHEMA_AFTER_MIGRATION"]
    
  end

end