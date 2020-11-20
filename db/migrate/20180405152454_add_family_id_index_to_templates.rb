class AddFamilyIdIndexToTemplates < ActiveRecord::Migration[4.2]
  def up
    add_index :templates, :family_id
  end

  def down
    remove_index :templates, :family_id
  end
end
