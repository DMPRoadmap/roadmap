# frozen_string_literal: true

# The following 2 values are used to tie the service to its IdentifierScheme.
# make sure the :name if lowercase
Rails.configuration.x.dmphub.name = "dmphub"
Rails.configuration.x.dmphub.description = "A DMPHub based DMP ID minting service: https://github.com/CDLUC3/dmphub"

# Credentials for minting DMP Ids via a DMPHub system: https://github.com/CDLUC3/dmphub
# To disable this feature, simply set 'active' to false
Rails.configuration.x.dmphub.landing_page_url = "http://localhost:3001/dmps/doi:"
Rails.configuration.x.dmphub.api_base_url = "http://localhost:3001/api/v0/"
Rails.configuration.x.dmphub.auth_path = "authenticate"
Rails.configuration.x.dmphub.mint_path = "data_management_plans"
Rails.configuration.x.dmphub.update_path = "data_management_plans"
Rails.configuration.x.dmphub.delete_path = "data_management_plans"

Rails.configuration.x.dmphub.callback_path = "data_management_plans/%{dmp_id}"
Rails.configuration.x.dmphub.callback_method = "patch"

Rails.configuration.x.dmphub.client_id = Rails.application.credentials.dmphub_client_id
Rails.configuration.x.dmphub.client_secret = Rails.application.credentials.dmphub_client_secret
Rails.configuration.x.dmphub.active = true
