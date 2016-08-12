class AddReleaseTimeToPlanSection < ActiveRecord::Migration
  def up
  	remove_column :plan_sections, :locked
  	add_column :plan_sections, :release_time, :datetime
  end
  
  def down
  	add_column :plan_sections, :locked, :boolean
  	remove_column :plan_sections, :release_time
  end
end
