class RemoveParentIdFromQuestions < ActiveRecord::Migration
  def change
    remove_column :questions, :parent_id, :integer
  end
end
