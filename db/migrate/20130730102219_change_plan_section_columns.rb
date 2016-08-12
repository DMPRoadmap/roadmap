class ChangePlanSectionColumns < ActiveRecord::Migration
	def up
		rename_column :plan_sections, :edit, :locked
		rename_column :plan_sections, :user_editing_id, :user_id
		remove_column :plan_sections, :at
	end

	def down
		rename_column :plan_sections, :locked, :edit
		rename_column :plan_sections, :user_id, :user_editing_id
		add_column :plan_sections, :at
	end
end
