class CreateMetadataStandardCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :fos do |t|
      t.string :uri
      t.string :identifier, null: false
      t.string :label, null: false
      t.references :parent, foreign_key: { to_table: :fos }
      t.timestamps
    end

    create_table :metadata_standards do |t|
      t.string :title
      t.text :description
      t.string :rdamsc_id
      t.string :uri
      t.json :locations
      t.json :related_entities
      t.timestamps
    end

    create_table :fos_metadata_standards do |t|
      t.references :fos, null: false
      t.references :metadata_standard, null: false
      t.timestamps
    end
  end
end
