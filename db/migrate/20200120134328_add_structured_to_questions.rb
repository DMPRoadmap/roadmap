class AddStructuredToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :structured, :boolean, null: false, default: false
  end
end
