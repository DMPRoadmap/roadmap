module DataCleanup
  module Rules
    module Template
      class FixBlankLocale < Rules::Base

        def description
          "Fix blank locale on template"
        end

        def call
          ::Template.where(locale: nil)
                    .update_all(locale: FastGettext.default_locale)
        end
      end
    end
  end
end
