class RemoveOrcidIdFromUsers < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :orcid_id
  end

  def down
    add_column :users, :orcid_id, :string
  end
end
