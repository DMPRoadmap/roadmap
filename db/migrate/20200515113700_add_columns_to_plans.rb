class AddColumnsToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :feedback_requestor, :integer
    add_column :plans, :feedback_request_date, :datetime
  end
end
