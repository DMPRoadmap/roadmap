class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.boolean :plan_locked
      t.integer :project_id
      t.integer :version_id

      t.timestamps
    end
  end
end
