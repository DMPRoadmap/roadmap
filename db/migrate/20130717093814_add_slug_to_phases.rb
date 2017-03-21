class AddSlugToPhases < ActiveRecord::Migration
  def change
    add_column :phases, :slug, :string
    add_index :phases, :slug, unique: true
  end
end
