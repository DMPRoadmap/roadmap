# frozen_string_literal: true

# Credentials for RDA Metadata Standards Catalog (RDAMSC)
# To disable this feature, simply set 'active' to false
Rails.configuration.x.rdamsc.landing_page_url = "http://rdamsc.bath.ac.uk"
Rails.configuration.x.rdamsc.api_base_url = "https://rdamsc.bath.ac.uk/"
Rails.configuration.x.rdamsc.schemes_path = "api2/m"
Rails.configuration.x.rdamsc.thesaurus_path = "api2/thesaurus/concepts"
Rails.configuration.x.rdamsc.active = true
