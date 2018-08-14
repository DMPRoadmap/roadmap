class RemoveQuestionIdFromGuidances < ActiveRecord::Migration
  def up
    remove_column :guidances, :question_id
  end

  def down
    add_column :guidances, :question_id, :integer
  end
end
