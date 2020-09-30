class AddDefaultValueToOptionalSubsetOnGuidanceGroups < ActiveRecord::Migration[4.2]
  def up
    change_column :guidance_groups, :optional_subset, :boolean, default: false, null: false
  end
  def down
    change_column :guidance_groups, :optional_subset, :boolean, default: nil, null: true
  end
end
