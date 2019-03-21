# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing description on Region
    module Region
      class FixMissingDescription < Rules::Base

        def description
          "Region: Set the name value for the missing description"
        end

        def call
          ::Region.where(description: ["", nil]).update_all("description=name")
        end
      end
    end
  end
end
