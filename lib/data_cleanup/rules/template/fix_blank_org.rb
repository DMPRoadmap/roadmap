# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank org on Template
    module Template
      class FixBlankOrg < Rules::Base

        def description
          "Fix blank org on Template"
        end

        def call
          ::Template.where("customization_of is not null and customization_of not in (?)", ::Template.all.pluck(:family_id)).each do |customization|
            log("Setting customization_of to NULL for Template without matching family_id: #{customization.family_id}")
            customization.update_attributes(customization_of: nil)
          end
        end
      end
    end
  end
end
