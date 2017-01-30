class AddFieldToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :option_comment_display, :boolean, :default => true

    if Object.const_defined?('Question')
      Question.find_each do |question|
        question.option_comment_display = true
        question.save!
      end
    end
  end
end
