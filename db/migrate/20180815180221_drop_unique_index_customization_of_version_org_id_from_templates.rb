class DropUniqueIndexCustomizationOfVersionOrgIdFromTemplates < ActiveRecord::Migration
  def up
    if index_exists?(:templates, [:customization_of, :version, :org_id])
      remove_index :templates, [:customization_of, :version, :org_id]
    end
  end

  def down
    add_index(:templates, [:customization_of, :version, :org_id], unique: true)
  end
end
