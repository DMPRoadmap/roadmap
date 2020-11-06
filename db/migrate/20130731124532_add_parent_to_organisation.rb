class AddParentToOrganisation < ActiveRecord::Migration[4.2]
  def change
    add_column :organisations, :parent_id, :integer
  end
end
