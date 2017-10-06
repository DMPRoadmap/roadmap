class AddOptionBasedToQuestionFormats < ActiveRecord::Migration
  def change
    add_column :question_formats, :option_based, :boolean, default: false
    
    # Set the new field to true for the question formats that have options
    if table_exists?('question_formats')
      QuestionFormat.all.each do |qf|
        unless ['text area', 'text field', 'date'].include?(qf.title.downcase)
          qf.option_based = true
          qf.save!
        end
      end
    end
  end
end
