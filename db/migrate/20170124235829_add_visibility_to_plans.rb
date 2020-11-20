class AddVisibilityToPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :plans, :visibility, :integer, null: false, default: 0
  end
end
