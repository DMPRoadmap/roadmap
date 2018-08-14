class RemoveSlugFromPhases < ActiveRecord::Migration
  def up
    if column_exists?(:phases, :slug)
      remove_column :phases, :slug
    end
  end

  def down
    add_column :phases, :slug, :string
  end
end
