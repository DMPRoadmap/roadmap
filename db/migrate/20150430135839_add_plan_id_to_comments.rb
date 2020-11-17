class AddPlanIdToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :plan_id, :integer
  end
end
