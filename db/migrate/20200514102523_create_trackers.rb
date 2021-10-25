class CreateTrackers < ActiveRecord::Migration[4.2]
  def change
    create_table :trackers do |t|
      t.references :org, index: true, foreign_key: true
      t.string :code

      t.timestamps null: false
    end
  end
end
