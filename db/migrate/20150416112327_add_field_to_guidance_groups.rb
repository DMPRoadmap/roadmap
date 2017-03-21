class AddFieldToGuidanceGroups < ActiveRecord::Migration
  def change
    add_column :guidance_groups, :published, :boolean
  end
end
