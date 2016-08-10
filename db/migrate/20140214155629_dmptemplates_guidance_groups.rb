class DmptemplatesGuidanceGroups < ActiveRecord::Migration
 	def change 
 		create_table :dmptemplates_guidance_groups, :id => false do |t|
      t.integer :dmptemplate_id
      t.integer :guidance_group_id
  	end
  end
end