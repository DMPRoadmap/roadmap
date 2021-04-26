class AddOrderToRegistryValue < ActiveRecord::Migration
  def change
    add_column :registry_values, :order, :integer
  end
end
