class CreateStats < ActiveRecord::Migration[4.2]
  def change
    create_table :stats do |t|
      t.bigint :count, default: 0
      t.date :date, null: false
      t.string :type, null: false
      t.belongs_to :org
      t.timestamps null: false
    end
  end
end
