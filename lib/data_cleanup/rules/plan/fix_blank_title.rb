module DataCleanup
  module Rules
    module Plan
      class FixBlankTitle < Rules::Base

        def description
          "Fix blank title on Plan"
        end

        def call
          ids = ::Plan.where(title: [nil, '']).ids
          ::Plan.find(ids).each do |plan|
            log("Adding default title to Plan##{plan.id}")
            plan.update(title: "My plan (#{plan.template.title})")
          end
        end
      end
    end
  end
end
