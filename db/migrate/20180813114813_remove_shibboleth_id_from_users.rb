class RemoveShibbolethIdFromUsers < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :shibboleth_id
  end

  def down
    add_column :users, :shibboleth_id, :string
  end
end
