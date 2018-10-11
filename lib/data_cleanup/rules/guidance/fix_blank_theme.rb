# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Answer
    module Guidance
      class FixBlankTheme < Rules::Base

        def description
          "Fix blank theme on Published Guidance"
        end

        def call
          ::Guidance.includes(:themes).each do |g|
            if g.themes.blank? && g.published?
              g.update!(published: false)
            end
          end
        end

      end
    end
  end
end
