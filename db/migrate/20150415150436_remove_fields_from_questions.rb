class RemoveFieldsFromQuestions < ActiveRecord::Migration
  def change
    remove_column :questions, :question_type
    remove_column :questions, :multiple_choice  
    remove_column :questions, :multiple_permitted
    remove_column :questions, :is_expanded
    remove_column :questions, :is_text_field
  end

end
