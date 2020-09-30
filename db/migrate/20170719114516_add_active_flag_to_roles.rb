class AddActiveFlagToRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :roles, :active, :boolean, default: true
  end
end
