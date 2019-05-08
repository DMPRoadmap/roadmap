class AddZenodoIdToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :zenodo_id, :integer
    add_index :plans, :zenodo_id
  end
end
