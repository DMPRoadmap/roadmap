class MadmpCleanup < ActiveRecord::Migration[5.2]
  def change

    # Decided not to ask users for the mime type when defining research outputs
    drop_table :mime_types
    remove_column :research_outputs, :mime_type_id

    # Remove attributes found in the RDA common standard that we decided not to use
    remove_column :research_outputs, :mandatory_attribution
    remove_column :research_outputs, :coverage_region
    remove_column :research_outputs, :coverage_start
    remove_column :research_outputs, :coverage_end

    # We're going to move towards a different solution allowing multiple api_clients
    # to have an interest in a plan
    remove_column :plans, :api_client_id

    # Remove the old principal_investigator and data_contact fields since they now
    # live in the contributors table
    remove_column :plans, :data_contact
    remove_column :plans, :data_contact_email
    remove_column :plans, :data_contact_phone

    remove_column :plans, :principal_investigator
    remove_column :plans, :principal_investigator_email
    remove_column :plans, :principal_investigator_identifier
    remove_column :plans, :principal_investigator_phone


    # Remove the old funder and grant fields since they have been replaced by associations
    remove_column :plans, :funder_name
    remove_column :plans, :grant_number
  end
end
