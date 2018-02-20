class AddFeedbackRequestedToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :feedback_requested, :boolean, default: false
  end
end
