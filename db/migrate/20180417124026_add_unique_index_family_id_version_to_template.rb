class AddUniqueIndexFamilyIdVersionToTemplate < ActiveRecord::Migration[4.2]
  def change
    add_index(:templates, [:family_id, :version], unique: true)
  end
end
