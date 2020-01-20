class CreateStructuredDataSchemas < ActiveRecord::Migration
  def change
    create_table :structured_data_schemas do |t|
      t.string :label
      t.string :name
      t.integer :version
      t.json :schema
      t.integer :org_id
      t.string :object

      t.timestamps null: false
    end
  end
end
