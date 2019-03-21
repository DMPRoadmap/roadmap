# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing language on Org
    module Org
      class FixMissingLanguage < Rules::Base

        def description
          "Org: Set French as  for Org with missing language"
        end

        def call
          ::Org.where(language_id: nil).update_all({language_id: ::Language.find_by(name: "Français")})
        end
      end
    end
  end
end
