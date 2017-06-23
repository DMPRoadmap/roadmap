class AddVisibilityToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :visibility, :integer, null: false, default: 0
  end
end
