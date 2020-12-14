# frozen_string_literal: true

# These configuration settings are used to communicate with the
# Open Aire Research Project Registry API. For more information about
# the API and to verify that your configuration settings are correct.
Rails.configuration.x.open_aire.api_base_url = "https://api.openaire.eu/"
# The api_url should contain `%s. This is where the funder is appended!
Rails.configuration.x.open_aire.search_path = "projects/dspace/%s/ALL/ALL"
Rails.configuration.x.open_aire.default_funder = "H2020"
Rails.configuration.x.open_aire.active = true
