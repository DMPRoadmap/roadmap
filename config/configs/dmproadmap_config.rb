# frozen_string_literal: true

# AnywayConfig is a gem that allows you to access any of your configuration variables (regardless of
# which of the various Rails's config value stores you use: ENV variables, /config/*.yml files or
# the encrypted credentials file) in the same way.
#
# See the docs for full details on AnywayConfig: https://github.com/palkan/anyway_config
#
# See config/dmproadmap.yml for an explanation of each atrribute's purpose
#
class DmproadmapConfig < Anyway::Config
  attr_config :api_documentation_urls,
              :api_max_page_size,
              :archived_accounts_email_suffix,

              :blog_rss,

              :cache_org_selection_expiration,
              :cache_research_projects_expiration,
              :contact_us_url,
              :cookie_key,
              :csv_separators,

              :database_adapter,
              :database_name,
              :database_pool_size,
              :database_host,
              :database_username,
              :database_password,
              :devise_secret,
              :devise_pepper,
              :dmphub_active,
              :dmphub_url,
              :dmphub_client_id,
              :dmphub_client_secret,
              :dmphub_landing_page_url,
              :do_not_reply_email,
              :doi_minting,
              :dragonfly_aws,
              :dragonfly_bucket,
              :dragonfly_host,
              :dragonfly_root_path,
              :dragonfly_secret,
              :dragonfly_url_scheme,

              :email_from_address,

              :google_analytics_tracker_root,

              :helpdesk_email,

              :issue_list_url,

              :locales_default,
              :locales_gettext_join_character,
              :locales_i18n_join_character,

              :restrict_orgs,
              :max_number_links_funder,
              :max_number_links_org,
              :max_number_links_sample_plan,
              :max_number_themes_per_column,

              :name,

              :openaire_active,
              :orcid_client_id,
              :orcid_client_secret,
              :orcid_sandbox,
              :organisation_abbreviation,
              :organisation_address_line1,
              :organisation_address_line2,
              :organisation_address_line3,
              :organisation_address_line4,
              :organisation_copywrite_name,
              :organisation_country,
              :organisation_google_maps_link,
              :organisation_name,
              :organisation_phone,
              :organisation_url,

              :plans_default_percentage_answered,
              :plans_default_visibility,
              :plans_org_admins_read_all,
              :plans_super_admins_read_all,
              :port,
              :preferences,
              :preferred_licenses,
              :preferred_licenses_guidance_url,

              :rails_log_to_stdout,
              :rails_max_threads,
              :rails_serve_static_files,
              :re3data_active,
              :recaptcha_enabled,
              :recaptcha_site_key,
              :recaptcha_secret_key,
              :release_notes_url,
              :results_per_page,
              :rollbar_env,
              :rollbar_access_token,
              :ror_active,

              :server_host,
              :shibboleth_enabled,
              :shibboleth_login_url,
              :shibboleth_logout_url,
              :shibboleth_use_filtered_discovery_service,
              :spdx_active,

              :translation_io_key,

              :user_group_subscription_url,
              :usersnap_key,

              :web_concurrency,
              :welcome_links,
              :wkhtmltopdf_path

  # If any of these attributes are missing the application will fail to start
  required :cookie_key,

           :database_adapter,
           :database_host,
           :database_username,
           :devise_pepper,
           :do_not_reply_email,
           :doi_minting,

           :helpdesk_email,

           :locales_default,

           :max_number_links_funder,
           :max_number_links_org,
           :max_number_links_sample_plan,
           :max_number_themes_per_column,

           :name,

           :orcid_client_id,
           :orcid_client_secret,
           :orcid_sandbox,

           :port,
           :plans_default_visibility,
           :plans_default_percentage_answered,
           :plans_org_admins_read_all,
           :plans_super_admins_read_all,
           :preferences,

           :re3data_active,
           :recaptcha_enabled,

           :server_host,
           :shibboleth_enabled,
           :spdx_active

           :wkhtmltopdf_path

end
