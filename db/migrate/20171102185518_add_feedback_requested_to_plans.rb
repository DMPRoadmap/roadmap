class AddFeedbackRequestedToPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :plans, :feedback_requested, :boolean, default: false
  end
end
