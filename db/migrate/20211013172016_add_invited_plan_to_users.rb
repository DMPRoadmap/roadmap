class AddInvitedPlanToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :invitation_plan_id, :integer
  end
end
