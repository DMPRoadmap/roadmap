class CreateTrackers < ActiveRecord::Migration
  def change
    create_table :trackers do |t|
      t.references :org, index: true, foreign_key: true
      t.string :code

      t.timestamps null: false
    end
  end
end
