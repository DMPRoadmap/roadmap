class ExtendStructureForApiAuthentication < ActiveRecord::Migration
  def change

    add_column :token_permissions, :user_id, :integer
    add_column :token_permissions, :token_permission_type_id, :integer
    remove_column :token_permissions, :token_type, :integer

    rename_column :org_token_permissions, :token_type, :token_permission_type_id

  end
end
