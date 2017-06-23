class AddDirtyToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :dirty, :boolean, default: false
  end
end
