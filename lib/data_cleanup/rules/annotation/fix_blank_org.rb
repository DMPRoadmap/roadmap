# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank org on Annotation
    module Annotation
      class FixBlankOrg < Rules::Base

        def description
          "Fix blank org on Annotation"
        end

        def call
          ids = ::Annotation.joins("LEFT OUTER JOIN orgs ON orgs.id = annotations.org_id")
                      .where(orgs: { id: nil }).ids
          log("Destroying Annotation without Org: #{ids}")
          ::Annotation.destroy(ids)
        end
      end
    end
  end
end
