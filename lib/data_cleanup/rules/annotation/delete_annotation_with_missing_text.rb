# frozen_string_literal: true
module DataCleanup
  module Rules
    # Delete Annotations with missing text
    module Annotation
      class DeleteAnnotationsWithMissingText < Rules::Base

        def description
          "Annotation: Delete Annotations with missing text"
        end

        def call
          ::Annotation.where(text: ["", nil]).destroy_all()
        end
      end
    end
  end
end
