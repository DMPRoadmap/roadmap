# frozen_string_literal: true

Rails.configuration.x.metadore.landing_page_url = ENV.fetch('METADORE_LANDING_PAGE_URL', 'http://localhost:3000/api-docs')
Rails.configuration.x.metadore.api_base_url = ENV.fetch('METADORE_API_BASE_URL', 'http://localhost:3000/')
Rails.configuration.x.metadore.search_path = ENV.fetch('METADORE_SEARCH_PATH', 'search')
Rails.configuration.x.metadore.active = ENV.fetch('METADORE_ENABLED', true)
Rails.configuration.x.metadore.size = ENV.fetch('METADORE_SEARCH_SIZE', 1000)
Rails.configuration.x.metadore.api_key = ENV.fetch('METADORE_API_KEY', 'changeme')
