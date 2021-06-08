class CreateRepositories < ActiveRecord::Migration[5.2]
  def change
    create_table :repositories do |t|
      t.string :name, null: false, index: true
      t.text :description, null: false
      t.string :url, index: true
      t.string :contact
      t.json :info
      t.timestamps
    end
  end
end
