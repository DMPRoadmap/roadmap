# frozen_string_literal: true

import OrgDateRangeable
import Role

class Org

  class CreateExportedPlanService

    class << self

      def call(org = nil)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: 2) do |org|
          OrgDateRangeable.split_months_from_creation(org) do |start_date, end_date|
            StatExportedPlan::CreateOrUpdate.do(
              start_date: start_date,
              end_date: end_date,
              org: org
            )
          end
        end
      end

    end

  end

end
