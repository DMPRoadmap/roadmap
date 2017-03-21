class AddQuestionFormatIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :question_format_id, :integer
  end
end
