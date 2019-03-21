# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing locale on Template
    module Template
      class FixMissingLocale < Rules::Base

        def description
          "Template: Set locale as 'fr_FR' for templates with missing locale"
        end

        def call
          ::Template.where(locale: nil).update_all({locale: "fr_FR"})
        end
      end
    end
  end
end
