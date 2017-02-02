class CreatePlanGuidanceGroups < ActiveRecord::Migration
  def change
    create_table :plan_guidance_groups do |t|
      t.references :plan, index: true, foreign_key: true
      t.references :guidance_group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
