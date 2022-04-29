class AddFunderAndOrgToPlans < ActiveRecord::Migration[4.2]
  def change
    add_reference :plans, :org, foreign_key: true
    add_column :plans, :funder_id, :integer, index: true
  end
end
