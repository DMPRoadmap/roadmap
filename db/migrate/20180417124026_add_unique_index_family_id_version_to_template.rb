class AddUniqueIndexFamilyIdVersionToTemplate < ActiveRecord::Migration
  def change
    add_index(:templates, [:family_id, :version], unique: true)
  end
end
