class AddIsExampleToSuggestedAnswers < ActiveRecord::Migration
  def change
    add_column :suggested_answers, :is_example, :boolean
  end
end
