class AddColumnsToStructuredAnswers < ActiveRecord::Migration[4.2]
  def change
    add_column :structured_answers, :dmp_id, :integer
    add_column :structured_answers, :parent_id, :integer
  end
end
