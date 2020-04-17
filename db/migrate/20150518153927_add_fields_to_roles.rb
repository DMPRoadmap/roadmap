class AddFieldsToRoles < ActiveRecord::Migration[4.2]
   def change
    add_column :roles, :resource_id, :integer  
    add_column :roles, :resource_type, :string
  end
end
