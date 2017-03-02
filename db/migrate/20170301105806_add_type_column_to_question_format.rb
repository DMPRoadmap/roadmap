class AddTypeColumnToQuestionFormat < ActiveRecord::Migration
  def self.up
    add_column  :question_formats, :formattype, :integer, :default => 0
    QuestionFormat.all.each do |qf|
      if qf.title == "Text area"
        qf.textarea = true
      end
      if qf.title == "Text field"
        qf.textfield = true
      end
      if qf.title == "Radio buttons"
        qf.radiobuttons = true
      end
      if qf.title == "Check box"
        qf.checkbox = true
      end
      if qf.title == "Dropdown"
        qf.dropdown = true
      end
      if qf.title == "Multi select box"
        qf.multiselectbox = true
      end
      if qf.title == "Date"
        qf.date = true
      end
      qf.save
    end
  end

  def self.down
    remove_column :question_formats, :formattype
  end
end
