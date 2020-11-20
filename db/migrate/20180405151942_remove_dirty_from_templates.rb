class RemoveDirtyFromTemplates < ActiveRecord::Migration[4.2]
  def up
    remove_column :templates, :dirty
  end
  
  def down
    add_column :templates, :dirty, :boolean, default: false
  end
end
