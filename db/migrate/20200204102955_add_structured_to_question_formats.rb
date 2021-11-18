class AddStructuredToQuestionFormats < ActiveRecord::Migration
  def change
    add_column :question_formats, :structured, :boolean, null: false, default: false
  end
end
