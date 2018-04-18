class AddUniqueIndexCustomizationOfVersionOrgIdToTemplate < ActiveRecord::Migration
  def change
    add_index(:templates, [:customization_of, :version, :org_id], unique: true)
  end
end
