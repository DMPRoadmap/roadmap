class AddMultipleChoiceAndMultiplePermittedAndIsExpandedToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :multiple_choice, :boolean
    add_column :questions, :multiple_permitted, :boolean
    add_column :questions, :is_expanded, :boolean
  end
end
