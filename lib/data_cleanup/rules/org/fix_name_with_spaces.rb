# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix name with space on Org
    module Org
      class FixNameWithSpace < Rules::Base

        def description
          "Fix name with leading or trailing space on Org"
        end

        def call
          ::Org.update_all("name = TRIM(name)")
        end
      end
    end
  end
end
