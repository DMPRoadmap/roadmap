class AddQuestionIdToGuidances < ActiveRecord::Migration
  def change
    add_column :guidances, :question_id, :integer
  end
end
