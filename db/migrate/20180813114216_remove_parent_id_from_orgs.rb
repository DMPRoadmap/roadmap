class RemoveParentIdFromOrgs < ActiveRecord::Migration[4.2]
  def up
    if column_exists?(:orgs, :parent_id)
      remove_column :orgs, :parent_id
    end
  end

  def down
    add_column :orgs, :parent_id, :integer
  end
end
