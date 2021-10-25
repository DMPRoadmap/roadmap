class RemoveFieldsFromRoles < ActiveRecord::Migration[4.2]
  def change
    remove_column :roles, :resource_id  
    remove_column :roles, :resource_type  
  end
end
