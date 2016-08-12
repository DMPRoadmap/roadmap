class LinkGuidanceGroupsToProjects < ActiveRecord::Migration
  def self.up
      create_table :project_guidance, :id => false do |t|
	  t.references :project, :null => false
	  t.references :guidance_group, :null => false
	end

    add_index :project_guidance, [:project_id, :guidance_group_id]
  end

  def self.down
    drop_table :project_guidance
  end
end
