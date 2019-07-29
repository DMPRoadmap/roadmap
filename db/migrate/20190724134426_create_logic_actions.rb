class CreateLogicActions < ActiveRecord::Migration
  def change
    create_table :logic_actions do |t|
      t.references :question_option, index: true, foreign_key: true
      t.integer :remove_question_id
      t.integer :action_type

      t.timestamps null: false
    end
  end
end
