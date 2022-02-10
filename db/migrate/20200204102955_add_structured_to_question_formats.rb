class AddStructuredToQuestionFormats < ActiveRecord::Migration[4.2]
  def change
    add_column :question_formats, :structured, :boolean, null: false, default: false
  end
end
