class AddQuestionFormatIdToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :question_format_id, :integer
  end
end
