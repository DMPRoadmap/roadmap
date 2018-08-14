# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank text on Annotation
    module Annotation

      class FixBlankText < Rules::Base

        def description
          "Fix blank text on Annotation"
        end

        def call
          ::Annotation.where(text: "").find_in_batches do |batches|
            batches.each do |annotation|
              log("Destroying Annotation##{annotation.id} since it has no text")
              annotation.destroy
            end
          end
        end

      end

    end
  end
end
