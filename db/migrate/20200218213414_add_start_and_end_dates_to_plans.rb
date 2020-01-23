class AddStartAndEndDatesToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :start_date, :datetime
    add_column :plans, :end_date, :datetime
  end
end
