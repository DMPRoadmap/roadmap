# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix nil published on Section
    module Section
      class FixNilPublished < Rules::Base

        def description
          "Fix nil published on Section"
        end

        def call
          ::Section.where(published: nil).update_all(published: false)
        end
      end
    end
  end
end
