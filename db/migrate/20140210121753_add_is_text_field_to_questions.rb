class AddIsTextFieldToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :is_text_field, :boolean
  end
end
