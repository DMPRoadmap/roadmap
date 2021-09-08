class AddDefaultToGuidanceGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :guidance_groups, :is_default, :boolean, default: false, index: true
  end
end
