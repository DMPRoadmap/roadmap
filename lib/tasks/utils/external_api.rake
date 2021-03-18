# frozen_string_literal: true

namespace :external_api do

  desc "Refresh the RDA Metadata Standards Catalog (RDAMSC) data"
  task refresh_rdamsc: :environment do
    Rake::Task["external_api:fetch_rdamsc_categories"].execute
    Rake::Task["external_api:fetch_rdamsc_standards"].execute
  end

  desc "Fetch the latest RDA Metadata Categories"
  task fetch_rdamsc_categories: :environment do
    p "Fetching the latest RDAMSC metadata categories and updating the metadata_standard_categories table"
    ExternalApis::RdamscService.fetch_metadata_categories
  end

  desc "Fetch the latest RDA Metadata Standards"
  task fetch_rdamsc_standards: :environment do
    p "Fetching the latest RDAMSC metadata standards and updating the metadata_standards table"
    ExternalApis::RdamscService.fetch_metadata_standards
  end

end