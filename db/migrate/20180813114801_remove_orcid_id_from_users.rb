class RemoveOrcidIdFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :orcid_id
  end

  def down
    add_column :users, :orcid_id, :string
  end
end
