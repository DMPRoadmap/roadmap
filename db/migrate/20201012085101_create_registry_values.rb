class CreateRegistryValues < ActiveRecord::Migration
  def change
    create_table :registry_values do |t|
      t.json :data
      t.belongs_to :registry, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
