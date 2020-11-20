class AddDirtyToTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :templates, :dirty, :boolean, default: false
  end
end
