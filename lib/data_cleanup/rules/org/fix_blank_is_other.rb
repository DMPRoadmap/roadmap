module DataCleanup
  module Rules
    module Org
      class FixBlankIsOther < Rules::Base

        def description
          "Fix nil values for is_other on Org"
        end

        def call
          ::Org.where(is_other: nil).update_all(is_other: false)
        end
      end
    end
  end
end
