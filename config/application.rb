# frozen_string_literal: true

require_relative "boot"

require "rails/all"

require "csv"

Bundler.require(*Rails.groups)

module DMPRoadmap

  class Application < Rails::Application
    # use default behaviours of rails 8
    config.load_defaults 8.0

    config.x.app_version = "2025.11"

    # ------------------------------------------ #
    # BASIC APPLICATION SETTINGS (STATIC CONFIG) #
    # ------------------------------------------ #
    begin
      config.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log", "daily")
      config.autoload_paths += %W[#{config.root}/lib]
      config.action_view.sanitized_allowed_tags = %w[p br strong em a table thead tbody tr td th tfoot caption ul ol li]
      config.filter_parameters += [:password]
      config.active_support.escape_html_entities_in_json = true
      config.action_controller.include_all_helpers = true

      Rails.application.config.assets.configure { |env| env.export_concurrent = false }
    end

    # ------------------ #
    # HOST CONFIGURATION #
    # ------------------ #
    begin
      ENV.fetch('DMPROADMAP_HOSTS').split(',').each do |host|
        config.hosts << host
      end
    end

    # ---------------------------- #
    # ENVIRONMENT CONFIGURATION   #
    # ---------------------------- #
    begin
      config.cache_classes = ENV["CACHE_CLASSES"]
      config.eager_load = ENV["EAGER_LOAD"]
      config.consider_all_requests_local = ENV["CONSIDER_ALL_REQUESTS_LOCAL"]
      config.action_controller.perform_caching = ENV["PERFORM_CACHING"]

      config.cache_store = ENV["CACHE_STORE"].to_sym
      config.active_storage.service = ENV["ACTIVE_STORAGE_SERVICE"].to_sym

      config.action_mailer.raise_delivery_errors = ENV["ACTION_MAILER_RAISE_DELIVERY_ERRORS"] == "true"
      config.action_mailer.delivery_method = ENV["ACTION_MAILER_DELIVERY_METHOD"].to_sym
      config.action_mailer.smtp_settings = {
        address: ENV["ACTION_MAILER_SMTP_SETTINGS_ADDRESS"],
        port: ENV["ACTION_MAILER_SMTP_SETTINGS_PORT"]
      }
      config.action_mailer.perform_caching = ENV["ACTION_MAILER_PERFORM_CACHING"] == "true"

      config.action_controller.allow_forgery_protection = ENV["ACTION_CONTROLLER_ALLOW_FORGERY_PROTECTION"] == "true"
      config.action_dispatch.show_exceptions = ENV["ACTION_DISPACTH_SHOW_EXCEPTIONS"] == "true"
      config.action_view.cache_template_loading = ENV["ACTION_VIEW_CACHE_TEMPLATE_LOADING"] == "true"

      config.public_file_server.enabled = ENV["PUBLIC_FILE_SERVER_ENABLED"] == "true"
      config.public_file_server.headers = {
        "Cache-Control" => [
          "public",
          "max-age=#{ENV["PUBLIC_FILE_SERVER_CACHE_SECONDS"]}",
          ENV["PUBLIC_FILE_SERVER_CACHE_EXTRA"].presence
        ].compact.join(", ")
      }

      config.log_level = ENV["LOG_LEVEL"]
      config.log_tags = ENV["LOG_TAGS"]
      config.log_formatter = Logger::Formatter.new

      config.active_support.deprecation = ENV["ACTIVE_SUPPORT_DEPRECATION"].to_sym
      config.active_support.disallowed_deprecation = ENV["ACTIVE_SUPPORT_DISALLOWED_DEPRECATION"].to_sym
      config.active_support.disallowed_deprecation_warnings = JSON.parse(ENV["ACTIVE_SUPPORT_DISALLOWED_DEPRECATION_WARNINGS"])

      config.active_record.migration_error = ENV["ACTIVE_RECORD_MIGRATION_ERROR"].to_sym
      config.active_record.verbose_query_logs = ENV["ACTIVE_RECORD_VERBOSE_QUERY_LOGS"] == "true"
      config.active_record.dump_schema_after_migration = ENV["ACTIVE_RECORD_DUMP_SCHEMA_AFTER_MIGRATION"] == "true"

      config.assets.debug = ENV["ASSETS_DEBUG"] == "true"
      config.assets.quiet = ENV["ASSETS_QUIET"] == "true"
      config.assets.compile = ENV["ASSETS_COMPILE"] == "true"

      config.file_watcher = ENV["FILE_WATCHER"].present? ? ENV["FILE_WATCHER"].constantize : nil
      config.require_master_key = ENV["REQUIRE_MASTER_KEY"] == "true"
      config.i18n.enforce_available_locales = ENV["I18N_ENFORCE_AVAILABLE_LOCALES"] == "true"
      config.i18n.fallbacks = ENV["I18N_FALLBACKS"] == "true"

      if ENV["RAILS_LOG_TO_STDOUT"] == "true"
        logger = ActiveSupport::Logger.new($stdout)
        logger.formatter = config.log_formatter
        config.logger = ActiveSupport::TaggedLogging.new(logger)
      end
    end

    # ---------------------------- #
    # ORGANISATION CONFIGURATION  #
    # ---------------------------- #
    begin
      config.x.organisation.name = ENV['ORGANISATION_NAME']
      config.x.organisation.abbreviation = ENV['ORGANISATION_ABBREVIATION']
      config.x.organisation.url = ENV['ORGANISATION_URL']
      config.x.organisation.copywrite_name = ENV['ORGANISATION_COPYWRITE_NAME']
      config.x.organisation.email = ENV['ORGANISATION_EMAIL']
      config.x.organisation.do_not_reply_email = ENV['ORGANISATION_DO_NOT_REPLY_EMAIL']
      config.x.organisation.helpdesk_email = ENV['ORGANISATION_HELPDESK_EMAIL']
      config.x.organisation.telephone = ENV['ORGANISATION_TELEPHONE']
      config.x.organisation.address = {
        line_1: ENV['ORGANISATION_ADDRESS_LINE_1'],
        line_2: ENV['ORGANISATION_ADDRESS_LINE_2'],
        line_3: ENV['ORGANISATION_ADDRESS_LINE_3'],
        line_4: ENV['ORGANISATION_ADDRESS_LINE_4'],
        country: ENV['ORGANISATION_ADDRESS_COUNTRY']
      }
      config.x.organisation.google_maps_link = ENV['ORGANISATION_GOOGLE_MAPS_LINK']
    end

    # ---------------------------- #
    # APPLICATION CONFIGURATION   #
    # ---------------------------- #
    begin
      config.x.application.name = ENV['APPLICATION_NAME']
      config.x.application.archived_accounts_email_suffix = ENV['APPLICATION_ARCHIVED_ACCOUNTS_EMAIL_SUFFIX']
      config.x.application.csv_separators = [',', '|', '#']
      config.x.application.api_max_page_size = ENV['APPLICATION_API_MAX_PAGE_SIZE']

      config.x.application.api_documentation_urls = {
        v0: ENV['APPLICATION_API_DOCUMENTATION_URLS_VO'],
        v1: ENV['APPLICATION_API_DOCUMENTATION_URLS_V1']
      }

      config.x.application.welcome_links = (1..3).map do |i|
        {
          title: ENV["APPLICATION_WELCOME_LINK_TITLE_#{i}"],
          url: ENV["APPLICATION_WELCOME_LINK_URL_#{i}"]
        }
      end

      config.x.application.preferences = {
        email: {
          users: {
            new_comment: ENV['APPLICATION_PREFERENCES_EMAIL_USERS_NEW_COMMENT'],
            admin_privileges: ENV['APPLICATION_PREFERENCES_EMAIL_USERS_ADMIN_PRIVILEGES'],
            added_as_coowner: ENV['APPLICATION_PREFERENCES_EMAIL_USERS_ADDED_AS_COOWNER'],
            feedback_requested: ENV['APPLICATION_PREFERENCES_EMAIL_USERS_FEEDBACK_REQUESTED'],
            feedback_provided: ENV['APPLICATION_PREFERENCES_EMAIL_USERS_FEEDBACK_PROVIDED']
          },
          owners_and_coowners: {
            visibility_changed: ENV['APPLICATION_PREFERENCES_OWNERS_AND_COOWNERS_VISIBILITY_CHANGED']
          }
        }
      }

      config.x.application.restrict_orgs = ENV['APPLICATION_RESTRICT_ORGS']
      config.x.application.display_contributor_phone_number = ENV['APPLICATION_DISPLAY_CONTRIBUTOR_PHONE_NUMBER']
      config.x.application.require_contributor_name = ENV['APPLICATION_REQUIRE_CONTRIBUTOR_NAME']
      config.x.application.require_contributor_email = ENV['APPLICATION_REQUIRE_CONTRIBUTOR_EMAIL']
      config.x.application.guidance_comments_toggleable = ENV['APPLICATION_GUIDANCE_COMMENTS_TOGGLEABLE']
      config.x.application.guidance_comments_opened_by_default = ENV['APPLICATION_GUIDANCE_COMMENTS_OPENED_BY_DEFAULT']
    end

    # -------------------- #
    # SHIBBOLETH SETTINGS  #
    # -------------------- #
    begin
      config.x.shibboleth.enabled = true
      config.x.shibboleth.login_url = '/Shibboleth.sso/Login'
      config.x.shibboleth.logout_url = '/Shibboleth.sso/Logout?return='
      config.x.shibboleth.use_filtered_discovery_service = false
    end

    # -------------------- #
    # LOCALE CONFIGURATION #
    # -------------------- #
    begin
      config.x.locales.default = 'en-GB'
      config.x.locales.i18n_join_character = '-'
      config.x.locales.gettext_join_character = '_'
    end

    # -------------------- #
    # SYSTEM THRESHOLDS    #
    # -------------------- #
    begin
      config.x.max_number_links_funder = 5
      config.x.max_number_links_sample_plan = 5
      config.x.max_number_themes_per_column = 5
      config.x.results_per_page = 10
    end

    # -------------------- #
    # PLAN DEFAULTS        #
    # -------------------- #
    begin 
      config.x.plans.default_visibility = 'privately_visible'
      config.x.plans.default_percentage_answered = 50
      config.x.plans.org_admins_read_all = true
      config.x.plans.super_admins_read_all = true
      config.x.plans.download_coversheet_tickbox_checked = false
    end 

    # -------------------- #
    # CACHING DURATIONS    #
    # -------------------- #
    begin
      config.x.cache.org_selection_expiration = 86_400
      config.x.cache.research_projects_expiration = 86_400
    end

    # -------------------- #
    # GOOGLE ANALYTICS     #
    # -------------------- #
    begin 
      config.x.google_analytics.tracker_root = ''    
    end

    # -------------------- #
    # RECAPTCHA SETTINGS   #
    # -------------------- #
    begin
      config.x.recaptcha.enabled = false
    end

    # -------------------- #
    # MA-DMP CONFIGURATION #
    # -------------------- #
    begin
      config.x.madmp.enable_ethical_issues = true
      config.x.madmp.enable_research_domain = true
      config.x.madmp.enable_research_outputs = true
      config.x.madmp.enable_license_selection = true
      config.x.madmp.enable_metadata_standard_selection = true
      config.x.madmp.enable_repository_selection = true

      config.x.madmp.extract_preservation_statements_from_themed_questions = false
      config.x.madmp.extract_data_quality_statements_from_themed_questions = false
      config.x.madmp.extract_security_privacy_statements_from_themed_questions = false

      config.x.madmp.preferred_licenses = [
        'CC-BY-%{latest}',
        'CC-BY-SA-%{latest}',
        'CC-BY-NC-%{latest}',
        'CC-BY-NC-SA-%{latest}',
        'CC-BY-ND-%{latest}',
        'CC-BY-NC-ND-%{latest}',
        'CC0-%{latest}'
      ]

      config.x.madmp.preferred_licenses_guidance_url = 'https://creativecommons.org/about/cclicenses/'
    end
    
  end

end