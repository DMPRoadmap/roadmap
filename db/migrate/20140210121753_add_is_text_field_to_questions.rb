class AddIsTextFieldToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :is_text_field, :boolean
  end
end
