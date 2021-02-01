class CreateRegistries < ActiveRecord::Migration
  def change
    create_table :registries do |t|
      t.string :name, null: false
      t.string :description
      t.string :uri
      t.integer :version
      t.belongs_to :org, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
