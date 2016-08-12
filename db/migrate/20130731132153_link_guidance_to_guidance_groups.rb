class LinkGuidanceToGuidanceGroups < ActiveRecord::Migration
  def self.up
      create_table :guidance_in_group, :id => false do |t|
	  t.references :guidance, :null => false
	  t.references :guidance_group, :null => false
	end

    add_index :guidance_in_group, [:guidance_id, :guidance_group_id]
  end

  def self.down
    drop_table :guidance_in_group
  end
end
