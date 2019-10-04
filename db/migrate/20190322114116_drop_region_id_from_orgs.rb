class DropRegionIdFromOrgs < ActiveRecord::Migration
  def change
    remove_column :orgs, :region_id, :integer
  end
end
