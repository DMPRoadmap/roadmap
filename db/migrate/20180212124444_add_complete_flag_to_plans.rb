class AddCompleteFlagToPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :plans, :complete, :boolean, default: false
  end
end
