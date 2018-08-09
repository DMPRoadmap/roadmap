module DataCleanup
  module Rules
    module GuidanceGroup
      class FixBlankOptionalSubset < Rules::Base

        def description
          "Fix blank optional subset on GuidanceGroup"
        end

        def call
          ::GuidanceGroup.where(optional_subset: nil)
                         .update_all(optional_subset: false)
        end
      end
    end
  end
end
