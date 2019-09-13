class CreateConditions < ActiveRecord::Migration
  def change
    create_table :conditions do |t|
      t.references :question_option, index: true, foreign_key: true
      t.integer :remove_question_id
      t.integer :action_type
      t.integer :number
      t.string :webhook_data

      t.timestamps null: false
    end
  end
end
