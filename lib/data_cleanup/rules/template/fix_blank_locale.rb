module DataCleanup
  module Rules
    module Template
      class FixBlankLocale < Rules::Base

        def description
          "Fix blank locale on template"
        end

        def call
          ids = ::Template.where(locale: [nil, ""]).ids
          log("Setting locale to #{FastGettext.default_locale} for Templates #{ids}")
          ::Template.where(id: ids).update_all(locale: FastGettext.default_locale)
        end
      end
    end
  end
end
