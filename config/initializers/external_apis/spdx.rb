# frozen_string_literal: true

# These configuration settings are used to communicate with the SPDX License repository.
# Licenses are loaded via a Rake task and stored in the local :licenses DB table.
# Please refer to: http://spdx.org/licenses/
Rails.configuration.x.spdx.landing_page_url = "http://spdx.org/licenses/"
Rails.configuration.x.spdx.api_base_url = "https://raw.githubusercontent.com/spdx/license-list-data/"
Rails.configuration.x.spdx.list_path = "master/json/licenses.json"
Rails.configuration.x.spdx.active = true
