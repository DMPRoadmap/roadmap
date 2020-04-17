class CreateExportedPlans < ActiveRecord::Migration[4.2]
  def change
    create_table :exported_plans do |t|
      t.references :plan
      t.references :user
      t.string :format
      t.timestamps
    end
  end
end
