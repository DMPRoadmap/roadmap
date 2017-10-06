class RemoveUnusedFieldsFromDmptemplates < ActiveRecord::Migration
  def change
    remove_column :dmptemplates, :user_id, :integer
  end
end
