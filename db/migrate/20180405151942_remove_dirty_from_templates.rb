class RemoveDirtyFromTemplates < ActiveRecord::Migration
  def up
    remove_column :templates, :dirty
  end
  
  def down
    add_column :templates, :dirty, :boolean, default: false
  end
end
