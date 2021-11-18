class AddStructuredToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :structured, :boolean, null: false, default: false
  end
end
