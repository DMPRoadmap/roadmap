# frozen_string_literal: true

# These configuration settings are used to communicate with the
# Research Organization Registry (ROR) API. For more information about
# the API and to verify that your configuration settings are correct,
# please refer to: https://github.com/ror-community/ror-api
Rails.configuration.x.ror.landing_page_url = "https://ror.org/"
Rails.configuration.x.ror.api_base_url = "https://api.ror.org/"
Rails.configuration.x.ror.heartbeat_path = "heartbeat"
Rails.configuration.x.ror.search_path = "organizations"
Rails.configuration.x.ror.max_pages = 2
Rails.configuration.x.ror.max_results_per_page = 20
Rails.configuration.x.ror.max_redirects = 3
Rails.configuration.x.ror.active = true
