class CreateConditions < ActiveRecord::Migration[4.2]
  def change
    create_table :conditions do |t|
      t.references :question, index: true, foreign_key: true
      t.text :option_list
      t.integer :action_type
      t.integer :number
      t.text :remove_data
      t.text :webhook_data

      t.timestamps null: false
    end
  end
end
