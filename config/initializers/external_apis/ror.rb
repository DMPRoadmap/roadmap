# frozen_string_literal: true

# These configuration settings are used to communicate with the
# Research Organization Registry (ROR) API. For more information about
# the API and to verify that your configuration settings are correct,
# please refer to: https://github.com/ror-community/ror-api
Rails.configuration.x.ror.download_url = 'https://zenodo.org/api/communities/ror-data/records?q=&sort=newest'
Rails.configuration.x.ror.landing_page_url = 'https://ror.org/'
Rails.configuration.x.ror.api_base_url = 'https://api.ror.org/'
Rails.configuration.x.ror.heartbeat_path = 'heartbeat'
Rails.configuration.x.ror.search_path = 'organizations'
Rails.configuration.x.ror.max_pages = 2
Rails.configuration.x.ror.max_results_per_page = 20
Rails.configuration.x.ror.max_redirects = 3
Rails.configuration.x.ror.active = Rails.configuration.x.dmproadmap.ror_active

Rails.configuration.x.ror.full_catalog_file = Rails.root.join('tmp', 'ror', 'ror.json')
Rails.configuration.x.ror.file_dir = Rails.root.join('tmp', 'ror')
Rails.configuration.x.ror.checksum_file = Rails.root.join('tmp', 'ror', 'checksum.txt')
Rails.configuration.x.ror.zip_file = Rails.root.join('tmp', 'ror', 'latest-ror-data.zip')
