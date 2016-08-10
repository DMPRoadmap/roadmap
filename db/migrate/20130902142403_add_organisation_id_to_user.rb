class AddOrganisationIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :organisation_id, :integer
  end
end
