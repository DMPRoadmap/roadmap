class MadmpCleanup < ActiveRecord::Migration[5.2]
  def change

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
