class RemoveUnusedFieldsFromDmptemplates < ActiveRecord::Migration[4.2]
  def change
    remove_column :dmptemplates, :user_id, :integer
  end
end
