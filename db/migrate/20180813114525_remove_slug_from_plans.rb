class RemoveSlugFromPlans < ActiveRecord::Migration[4.2]
  def up
    if column_exists?(:plans, :slug)
      remove_column :plans, :slug
    end
  end

  def down
    add_column :plans, :slug, :string
  end
end
