class AddSlugToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :slug, :string
    add_index :plans, :slug, unique: true
  end
end
