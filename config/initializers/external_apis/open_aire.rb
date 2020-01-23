# frozen_string_literal: true

# These configuration settings are used to communicate with the
# Open Aire Research Project Registry API. For more information about
# the API and to verify that your configuration settings are correct,
# please refer to: https://github.com/ror-community/ror-api
Rails.configuration.x.open_aire.api_url = "https://api.openaire.eu/projects/dspace/%s/ALL/ALL"
Rails.configuration.x.open_aire.default_funder = "H2020"
Rails.configuration.x.open_aire.active = false
