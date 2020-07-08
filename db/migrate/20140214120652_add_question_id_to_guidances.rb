class AddQuestionIdToGuidances < ActiveRecord::Migration[4.2]
  def change
    add_column :guidances, :question_id, :integer
  end
end
