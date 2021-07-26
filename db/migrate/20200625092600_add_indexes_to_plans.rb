class AddIndexesToPlans < ActiveRecord::Migration
  def change
    add_index :plans, :org_id
    add_index :plans, :funder_id
    add_index :plans, :grant_id
  end
end
