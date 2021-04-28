# frozen_string_literal: true

# The following 2 values are used to tie the service to its IdentifierScheme.
# make sure the :name if lowercase
Rails.configuration.x.orcid.name = "orcid"

# Credentials for the ORCID member API are pulled in from the Devise omniauth config
# To disable this feature, simply set 'active' to false
Rails.configuration.x.orcid.landing_page_url = "https://orcid.org/"
Rails.configuration.x.orcid.auth_path = "activities/update"
Rails.configuration.x.orcid.works_path = "works/"
Rails.configuration.x.orcid.work_path = "work/"

Rails.configuration.x.orcid.callback_path = "data_management_plans/%{dmp_id}"
Rails.configuration.x.orcid.callback_method = "patch"
Rails.configuration.x.orcid.active = true
