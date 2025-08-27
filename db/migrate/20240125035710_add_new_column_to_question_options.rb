class AddNewColumnToQuestionOptions < ActiveRecord::Migration[6.1]
  def change
    add_column :question_options, :answer_identifier, :string
  end
end
