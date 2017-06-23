class DropUnusedUserTables < ActiveRecord::Migration
  def change
    drop_table :user_statuses
    remove_column :users, :user_status_id
    drop_table :user_role_types
    drop_table :user_types
    remove_column :users, :user_type_id
  end
end
