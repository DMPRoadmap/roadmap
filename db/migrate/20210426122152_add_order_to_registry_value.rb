class AddOrderToRegistryValue < ActiveRecord::Migration[4.2]
  def change
    add_column :registry_values, :order, :integer
  end
end
