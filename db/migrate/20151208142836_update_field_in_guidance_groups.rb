class UpdateFieldInGuidanceGroups < ActiveRecord::Migration
  def change
    if Object.const_defined?('GuidanceGroup')
     GuidanceGroup.find_each do |guidance_group|
        guidance_group.published = true
        guidance_group.save!
     end
   end
  end
end
