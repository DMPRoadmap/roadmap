class AddFieldToGuidanceGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :guidance_groups, :published, :boolean
  end
end
