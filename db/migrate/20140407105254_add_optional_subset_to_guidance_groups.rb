class AddOptionalSubsetToGuidanceGroups < ActiveRecord::Migration[4.2]
  def change
  	add_column :guidance_groups, :optional_subset, :boolean
  end
end
