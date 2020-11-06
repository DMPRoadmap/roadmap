class AddSlugToPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :plans, :slug, :string
    add_index :plans, :slug, unique: true
  end
end
