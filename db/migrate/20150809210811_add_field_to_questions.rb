class AddFieldToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :option_comment_display, :boolean, :default => true

    if table_exists?('questions')
      Question.find_each do |question|
        question.option_comment_display = true
        question.save!
      end
    end
  end
end
