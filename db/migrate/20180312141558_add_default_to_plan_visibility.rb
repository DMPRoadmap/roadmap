class AddDefaultToPlanVisibility < ActiveRecord::Migration
  def up
    change_column_default(:plans, :visibility, Plan.visibilities[:privately_visible])
  end
  def down
    change_column_default(:plans, :visibility, nil)
  end
end