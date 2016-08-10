class RemoveFieldsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :password
    remove_column :users, :login_count  
    remove_column :users, :last_login
    remove_column :users, :invitation_limit
    remove_column :users, :invited_by_id
    remove_column :users, :invited_by_type
  end
end
