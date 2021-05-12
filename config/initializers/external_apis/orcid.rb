# frozen_string_literal: true

# The following 2 values are used to tie the service to its IdentifierScheme.
# make sure the :name if lowercase
Rails.configuration.x.orcid.name = "orcid"

# Credentials for the ORCID member API are pulled in from the Devise omniauth config
# To disable this feature, simply set 'active' to false
Rails.configuration.x.orcid.landing_page_url = Rails.configuration.x.orcid_landing_page_url
Rails.configuration.x.orcid.api_base_url = Rails.configuration.x.orcid_api_base_url
Rails.configuration.x.orcid.work_path = "%{id}/work/"
Rails.configuration.x.orcid.callback_path = "work/%{put_code}"
Rails.configuration.x.orcid.active = true