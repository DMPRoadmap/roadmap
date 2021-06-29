class AddFundingStatusToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :funding_status, :integer, null: true
  end
end
