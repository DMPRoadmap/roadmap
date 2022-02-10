class AddIsCommonToAnswers < ActiveRecord::Migration[4.2]
  def change
    add_column :answers, :is_common, :boolean, default: false
  end
end
