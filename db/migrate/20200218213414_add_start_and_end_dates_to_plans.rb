class AddStartAndEndDatesToPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :plans, :grant_id, :integer, index: true
    add_column :plans, :start_date, :datetime
    add_column :plans, :end_date, :datetime
  end
end
