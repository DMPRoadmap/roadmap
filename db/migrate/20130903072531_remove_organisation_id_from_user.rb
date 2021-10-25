class RemoveOrganisationIdFromUser < ActiveRecord::Migration[4.2]
  def up
  	remove_column :users, :organisation_id
  end

  def down
  	add_column :users, :organisation_id, :integer
  end
end
