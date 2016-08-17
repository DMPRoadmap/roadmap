class UpdateFieldInGuidanceGroups < ActiveRecord::Migration
  def change
     GuidanceGroup.find_each do |guidance_group|
        guidance_group.published = true
        guidance_group.save!
     end
  end
end
