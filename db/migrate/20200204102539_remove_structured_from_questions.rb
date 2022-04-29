class RemoveStructuredFromQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :questions, :structured
  end
end
