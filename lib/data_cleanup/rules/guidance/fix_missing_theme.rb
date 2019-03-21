# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing theme on Guidance
    module Guidance
      class FixMissingTheme < Rules::Base

        def description
          "Guidance: Link the guidance without theme to the first theme available"
        end

        def call
          ::Guidance.includes(:themes).where(themes: {id: nil}).each do |guidance|
            guidance.themes << Theme.first
          end
        end
      end
    end
  end
end
