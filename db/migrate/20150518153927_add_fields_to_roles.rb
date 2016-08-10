class AddFieldsToRoles < ActiveRecord::Migration
   def change
    add_column :roles, :resource_id, :integer  
    add_column :roles, :resource_type, :string
  end
end
