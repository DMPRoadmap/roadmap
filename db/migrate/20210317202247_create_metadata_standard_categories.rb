class CreateMetadataStandardCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :metadata_categories do |t|
      t.string :uri, null: false
      t.string :label, null: false
      t.references :parent, foreign_key: { to_table: :metadata_categories }
      t.timestamps
    end

    create_table :metadata_standards do |t|
      t.string :title
      t.text :description
      t.string :rdamsc_id
      t.string :uri
      t.json :locations
      t.json :related_entities
      t.references :parent, foreign_key: { to_table: :metadata_standards }
      t.timestamps
    end

    create_table :metadata_categories_standards do |t|
      t.references :metadata_category, null: false
      t.references :metadata_standard, null: false
      t.timestamps
    end
  end
end
