class AddFieldToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :role_in_plans, :boolean
  end
end
