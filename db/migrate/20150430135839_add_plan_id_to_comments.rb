class AddPlanIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :plan_id, :integer
  end
end
