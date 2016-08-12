class RemoveFieldsFromRoles < ActiveRecord::Migration
  def change
    remove_column :roles, :resource_id  
    remove_column :roles, :resource_type  
  end
end
