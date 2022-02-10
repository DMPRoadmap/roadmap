class AddPhaseIdToExportedPlan < ActiveRecord::Migration[4.2]
  def up
    add_column :exported_plans, :phase_id, :integer
  end

  def down
    remove_column :exported_plans, :phase_id, :integer
  end
end
