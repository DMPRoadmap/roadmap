class AddParentToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :parent_id, :integer
  end
end
