class AddFieldToRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :roles, :role_in_plans, :boolean
  end
end
