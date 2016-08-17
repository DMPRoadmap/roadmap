class AddOptionalSubsetToGuidanceGroups < ActiveRecord::Migration
  def change
  	add_column :guidance_groups, :optional_subset, :boolean
  end
end
