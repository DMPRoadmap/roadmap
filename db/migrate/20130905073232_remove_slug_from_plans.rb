class RemoveSlugFromPlans < ActiveRecord::Migration
  def up
  	remove_column :plans, :slug
  end

  def down
  	add_column :plans, :slug, :string
  end
end
