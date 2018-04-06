class AddFamilyIdIndexToTemplates < ActiveRecord::Migration
  def up
    add_index :templates, :family_id
  end

  def down
    remove_index :templates, :family_id
  end
end
