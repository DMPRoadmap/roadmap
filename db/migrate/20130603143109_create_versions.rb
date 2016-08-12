class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :title
      t.text :description
      t.integer :published
      t.integer :number
      t.references :phase

      t.timestamps
    end
    add_index :versions, :phase_id
  end
end
