class CreatePlanSections < ActiveRecord::Migration
  def change
    create_table :plan_sections do |t|
      t.boolean :plan_section_edit
      t.datetime :plan_section_at
      t.integer :user_editing_id
      t.integer :section_id
      t.integer :plan_id

      t.timestamps
    end
  end
end
