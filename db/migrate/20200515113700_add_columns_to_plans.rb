class AddColumnsToPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :plans, :feedback_requestor, :integer
    add_column :plans, :feedback_request_date, :datetime
  end
end
