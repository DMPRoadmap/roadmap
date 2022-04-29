class CreateStructuredDataSchemas < ActiveRecord::Migration[4.2]
  def change
    create_table :structured_data_schemas do |t|
      t.string :label
      t.string :name
      t.integer :version
      t.json :schema
      t.integer :org_id
      t.belongs_to :org, foreign_key: true, index: true
      t.string :object

      t.timestamps null: false
    end
  end
end
