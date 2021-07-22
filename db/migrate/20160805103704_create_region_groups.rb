class CreateRegionGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :region_groups do |t|
      t.integer :super_region_id
      t.integer :region_id
    end
  end
end
