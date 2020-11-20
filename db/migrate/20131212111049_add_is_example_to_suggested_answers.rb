class AddIsExampleToSuggestedAnswers < ActiveRecord::Migration[4.2]
  def change
    add_column :suggested_answers, :is_example, :boolean
  end
end
