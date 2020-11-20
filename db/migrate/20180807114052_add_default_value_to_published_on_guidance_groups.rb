class AddDefaultValueToPublishedOnGuidanceGroups < ActiveRecord::Migration[4.2]
  def up
    change_column :guidance_groups, :published, :boolean, default: false, null: false
  end
  def down
    change_column :guidance_groups, :published, :boolean, default: nil, null: true
  end
end
