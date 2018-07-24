# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Answer
    module Answer
      class FixBlankUser < Rules::Base

        def description
          "Fix blank user on Answer"
        end

        def call
          ::Answer.where(user: nil).destroy_all
        end
      end
    end
  end
end
