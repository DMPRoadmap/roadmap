class AddTypeToTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :templates, :type, :integer, null: false, default: 0
  end
end
