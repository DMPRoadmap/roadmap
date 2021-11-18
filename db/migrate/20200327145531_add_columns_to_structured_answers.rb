class AddColumnsToStructuredAnswers < ActiveRecord::Migration
  def change
    add_column :structured_answers, :dmp_id, :integer
    add_column :structured_answers, :parent_id, :integer
  end
end
