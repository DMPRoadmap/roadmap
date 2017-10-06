class RenameRolesToPerms < ActiveRecord::Migration
  def self.up
    rename_table :roles, :perms
    rename_table :users_roles, :users_perms
    rename_column :users_perms, :role_id, :perm_id
    #remove_index :users_perms, 
  end

  def self.down
    #rename_index :users_perms,  :index_users_perms_on_user_id_and_perms_id, :index_users_roles_on_user_id_and_role_id
    rename_column :users_perms, :perm_id, :role_id
    rename_table :users_perms, :users_roles
    rename_table :perms, :roles
  end
end
