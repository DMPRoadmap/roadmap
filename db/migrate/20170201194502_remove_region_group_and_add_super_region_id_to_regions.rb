class RemoveRegionGroupAndAddSuperRegionIdToRegions < ActiveRecord::Migration
  def change
    drop_table :region_groups if table_exists?(:region_groups)
    
    add_column :regions, :super_region_id, :integer unless column_exists?(:regions, :super_region_id)
  end
end
