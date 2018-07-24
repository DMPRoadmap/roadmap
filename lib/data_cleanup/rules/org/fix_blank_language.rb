module DataCleanup
  module Rules
    module Org
      class FixBlankLanguage < Rules::Base

        DEFAULT_LANGUAGE = Language.find_by(abbreviation: FastGettext.default_locale)

        def description
          "Fix blank language on Org"
        end

        def call
          ::Org.where(language: nil).update_all(language_id: DEFAULT_LANGUAGE.id)
        end
      end
    end
  end
end
