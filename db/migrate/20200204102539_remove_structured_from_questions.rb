class RemoveStructuredFromQuestions < ActiveRecord::Migration
  def change
    remove_column :questions, :structured
  end
end
