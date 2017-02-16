class SingleGroupForGuidance < ActiveRecord::Migration
  def change
    unless Rails.env.test?
      if table_exists?('guidances')
        Guidance.class_eval do
          belongs_to :guidance_group, class_name: "GuidanceGroup", foreign_key: "guidance_group_id"
        end

        Guidance.includes( :guidance_groups).all.each do |guidance|
          guidance.guidance_group_id = guidance.guidance_groups.first.id unless guidance.guidance_groups.empty?
          if guidance.guidance_group_id.nil?
            guidance.destroy
          else
            guidance.save!
          end
        end
      end
    end

    drop_table :guidance_in_group
  end
end
