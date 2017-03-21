class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.text :answer_text
      t.integer :plan_id
      t.integer :user_id
      t.integer :question_id

      t.timestamps
    end
  end
end
