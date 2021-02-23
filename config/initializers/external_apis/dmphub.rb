# frozen_string_literal: true

# The following 2 values are used to tie the service to its IdentifierScheme.
# make sure the :name if lowercase
Rails.configuration.x.dmphub.name = "dmphub"
Rails.configuration.x.dmphub.description = "A DMPHub based DOI minting service: https://github.com/CDLUC3/dmphub"

# Credentials for minting DOIs via a DMPHub system: https://github.com/CDLUC3/dmphub
# To disable this feature, simply set 'active' to false
Rails.configuration.x.dmphub.landing_page_url = "https://doi.org/"
Rails.configuration.x.dmphub.auth_path = "authenticate"
Rails.configuration.x.dmphub.mint_path = "data_management_plans"
Rails.configuration.x.dmphub.update_path = "data_management_plans"
Rails.configuration.x.dmphub.delete_path = "data_management_plans"

Rails.configuration.x.dmphub.callback_path = "data_management_plans/%{dmp_id}"
Rails.configuration.x.dmphub.callback_method = "patch"

if Rails.env.development?
  Rails.configuration.x.dmphub.api_base_url = "http://localhost:3001/api/v0/"
  Rails.configuration.x.dmphub.client_id = "E0rukf2HM3DuQbWESclCzddYOY9j44ZJkflwoKhM6vM"
  Rails.configuration.x.dmphub.client_secret = "H3YtnycXQfFH6Lxbx7Sbazsx-DNKij8Z3Nsndfe4g6I"
else
  Rails.configuration.x.dmphub.api_base_url = ENV["DMPHUB_URL"]
  Rails.configuration.x.dmphub.client_id = Rails.application.credentials.dmphub[:client_id]
  Rails.configuration.x.dmphub.client_secret = Rails.application.credentials.dmphub[:client_secret]
end

Rails.configuration.x.dmphub.active = true
