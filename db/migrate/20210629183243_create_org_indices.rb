class CreateOrgIndices < ActiveRecord::Migration[5.2]
  def change
    create_table :org_indices do |t|
      t.references :org, index: true
      t.string :ror_id, index: true
      t.string :fundref_id, index: true
      t.string :name, index: true
      t.string :home_page
      t.string :language
      t.json :types
      t.json :acronyms
      t.json :aliases
      t.json :country
      t.datetime :file_timestamp, index: true
      t.timestamps
    end
  end
end
