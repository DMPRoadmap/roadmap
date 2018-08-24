module DataCleanup
  module Rules
    module Region
      class FixBlankDescription < Rules::Base

        def description
          "Fix blank description on region"
        end

        def call
          ::Region.where(description: [nil, '']).each do |region|
            log("Adding default description to Region##{region.id}")
            region.update!(description: "#{region.name} region")
          end
        end
      end
    end
  end
end
