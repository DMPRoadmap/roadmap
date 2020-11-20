class RemoveParentIdFromQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :questions, :parent_id, :integer
  end
end
