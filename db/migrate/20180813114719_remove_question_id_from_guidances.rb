class RemoveQuestionIdFromGuidances < ActiveRecord::Migration[4.2]
  def up
    remove_column :guidances, :question_id
  end

  def down
    add_column :guidances, :question_id, :integer
  end
end
