class AddReviewStatusToPlans < ActiveRecord::Migration
  def up
    add_column :plans, :review_status, :integer, default: 0, null: false
  end

  def down
    remove_column :plans, :review_status
  end
end
