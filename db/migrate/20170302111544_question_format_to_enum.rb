class QuestionFormatToEnum < ActiveRecord::Migration
  def self.up
    add_column  :question_formats, :formattype, :integer, :default => 0
    QuestionFormat.all.each do |qf|
      if qf.title == "Text area"
        qf.textarea!
      end
      if qf.title == "Text field"
        qf.textfield!
      end
      if qf.title == "Radio buttons"
        qf.radiobuttons!
      end
      if qf.title == "Check box"
        qf.checkbox!
      end
      if qf.title == "Dropdown"
        qf.dropdown!
      end
      if qf.title == "Multi select box"
        qf.multiselectbox!
      end
      if qf.title == "Date"
        qf.date!
      end
      qf.save
    end
  end

  def self.down
    remove_column :question_formats, :formattype
  end
end
