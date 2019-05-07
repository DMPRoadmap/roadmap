class AddIsCommonToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :is_common, :boolean, default: false
  end
end
