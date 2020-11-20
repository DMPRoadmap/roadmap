class AddSlugToPhases < ActiveRecord::Migration[4.2]
  def change
    add_column :phases, :slug, :string
    add_index :phases, :slug, unique: true
  end
end
