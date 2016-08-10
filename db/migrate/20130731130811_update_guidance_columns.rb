class UpdateGuidanceColumns < ActiveRecord::Migration
  def up
		rename_column :guidances, :organisation_id, :guidance_group_id
	end

	def down
		rename_column :guidances, :guidance_group_id, :organisation_id
	end
end
