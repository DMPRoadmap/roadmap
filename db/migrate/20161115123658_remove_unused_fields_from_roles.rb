class RemoveUnusedFieldsFromRoles < ActiveRecord::Migration[4.2]
  def change
    remove_column :roles, :role_in_plans, :boolean
    remove_column :roles, :resource_id, :integer
    remove_column :roles, :resource_type, :string
  end
end
