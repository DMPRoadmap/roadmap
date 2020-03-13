class AddParentIdToStructuredAnswer < ActiveRecord::Migration
  def change
    add_column :structured_answers, :parent_id, :integer
  end
end
