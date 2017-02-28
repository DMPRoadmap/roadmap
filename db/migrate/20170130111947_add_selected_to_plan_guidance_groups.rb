class AddSelectedToPlanGuidanceGroups < ActiveRecord::Migration
  def change
    add_column :plan_guidance_groups, :selected, :boolean
  end
end
