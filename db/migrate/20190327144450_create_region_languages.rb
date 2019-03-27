class CreateRegionLanguages < ActiveRecord::Migration
  def change
    create_table :region_languages do |t|
      t.references :region
      t.references :language
      t.boolean :default, null: false, default: false
      t.timestamps null: false
    end
  end
end
