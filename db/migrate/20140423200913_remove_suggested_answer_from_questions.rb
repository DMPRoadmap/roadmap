class RemoveSuggestedAnswerFromQuestions < ActiveRecord::Migration[4.2]
  def up
    remove_column :questions, :suggested_answer
  end

  def down
    add_column :questions, :suggested_answer, :text
  end
end
