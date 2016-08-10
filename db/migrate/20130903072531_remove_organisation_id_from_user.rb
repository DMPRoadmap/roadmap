class RemoveOrganisationIdFromUser < ActiveRecord::Migration
  def up
  	remove_column :users, :organisation_id
  end

  def down
  	add_column :users, :organisation_id, :integer
  end
end
