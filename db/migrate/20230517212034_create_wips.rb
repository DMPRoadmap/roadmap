class CreateWips < ActiveRecord::Migration[6.1]
  def change
    create_table :wips do |t|
      t.string :identifier, index: true
      t.json :metadata, null: false
      t.integer :user_id
      t.timestamps
    end
  end
end
