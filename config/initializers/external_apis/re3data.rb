# frozen_string_literal: true

# Credentials for minting DOIs via re3data
# To disable this feature, simply set 'active' to false
Rails.configuration.x.re3data.landing_page_url = "https://www.re3data.org/"
Rails.configuration.x.re3data.api_base_url = "https://www.re3data.org/api/v1/"
Rails.configuration.x.re3data.list_path = "repositories"
Rails.configuration.x.re3data.repository_path = "repository/"
Rails.configuration.x.re3data.active = true
