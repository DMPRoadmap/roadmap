class CreateMetadataStandardCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :fos do |t|
      t.string :uri
      t.string :identifier, null: false
      t.string :label, null: false
      t.text :keywords
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

    create_table :metadata_standards_research_outputs do |t|
      t.references :metadata_standard, null: true,  index: { name: "metadata_research_outputs_on_metadata" }
      t.references :research_output, null: true,  index: { name: "metadata_research_outputs_on_ro" }
    end

  end
end
