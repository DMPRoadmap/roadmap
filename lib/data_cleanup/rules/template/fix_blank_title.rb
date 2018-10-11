module DataCleanup
  module Rules
    module Template
      class FixBlankTitle < Rules::Base

        def description
          "Fix blank title on template"
        end

        def call
          ids = ::Template.where(title: [nil, ""]).ids
          log("Setting title to DEFAULT TITLE for Templates #{ids}")
          ::Template.where(id: ids).update_all(title: "DEFAULT TITLE")
        end
      end
    end
  end
end
