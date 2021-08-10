# frozen_string_literal: true

# The following 2 values are used to tie the service to its IdentifierScheme.
# make sue the :name if lowercase
Rails.configuration.x.datacite.name = "datacite"
Rails.configuration.x.datacite.description = "The DataCite REST API: https://support.datacite.org/docs/api-create-dois"

# Credentials for minting DMP IDs via DataCite
# To disable this feature, simply set 'active' to false
Rails.configuration.x.datacite.landing_page_url = "https://doi.org/"
Rails.configuration.x.datacite.api_base_url = "https://api.test.datacite.org/"
Rails.configuration.x.datacite.mint_path = "dois"
Rails.configuration.x.datacite.delete_path = "dois/"

# Define your organization as the hosting institution for the DataCite record.
# Datacite defines this as:
#    "Typically, the organisation allowing the resource to be available on the
#     internet through the provision of its hardware/software/operating support."
Rails.configuration.x.datacite.hosting_institution = "My Curation Centre (MCC)"
Rails.configuration.x.datacite.hosting_institution_identifier = "https://ror.org/12345"

# TODO: Move the :repository_id, :password and :shoulder to the credentials.yml.enc in Rails5
Rails.configuration.x.datacite.repository_id = Rails.application.credentials.datacite_repository_id
Rails.configuration.x.datacite.password = Rails.application.credentials.datacite_password
Rails.configuration.x.datacite.shoulder = Rails.application.credentials.datacite_shoulder
Rails.configuration.x.datacite.active = false
