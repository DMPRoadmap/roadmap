class AddFeedbackStartAtAndStopAtToPlans < ActiveRecord::Migration[6.1]
  def change
    add_column :plans, :feedback_start_at, :datetime
    add_column :plans, :feedback_end_at, :datetime
  end
end
