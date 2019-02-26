class CreateRegions < ActiveRecord::Migration
  def change
    remove_foreign_key "orgs", "regions"
    
    drop_table :regions
    create_table :regions do |t|
      t.string :name, null: false, limit: 30

      t.timestamps null: false
    end
  end
end
