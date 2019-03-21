# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing text on Annotation
    module Annotation
      class FixMissingText < Rules::Base

        def description
          "Annotation: Set text as 'Votre annotation' for Annotations with missing text"
        end

        def call
          ::Annotation.where(text: ["", nil]).update_all({text: "Votre annotation"})
        end
      end
    end
  end
end
