class AddFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :invited_by_id, :integer
    add_column :users, :invited_by_type, :string
  end
end
