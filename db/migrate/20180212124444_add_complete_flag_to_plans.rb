class AddCompleteFlagToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :complete, :boolean, default: false
  end
end
