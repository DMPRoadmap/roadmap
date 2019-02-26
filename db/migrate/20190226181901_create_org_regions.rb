class CreateOrgRegions < ActiveRecord::Migration
  def change
    create_table :org_regions do |t|
      t.references :org, index: true, foreign_key: true
      t.references :region, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
