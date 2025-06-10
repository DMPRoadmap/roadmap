# frozen_string_literal: true

# These configuration settings are used to communicate with the
# Open Aire Research Project Registry API. For more information about
# the API and to verify that your configuration settings are correct.
Rails.configuration.x.open_aire.api_base_url = 'https://api.openaire.eu/'
#DOI integration
Rails.configuration.x.open_aire.client_id = ENV['OPEN_AIRE_CLIENT_ID'] 
Rails.configuration.x.open_aire.client_secret = ENV['OPEN_AIRE_CLIENT_SECRET'] 
Rails.configuration.x.open_aire.grant_type = 'client_credentials'
Rails.configuration.x.open_aire.open_aire_access_token_endpoint = 'https://aai.openaire.eu/oidc/token'
Rails.configuration.x.open_aire.research_outputs_search_path = 'search/researchProducts'
