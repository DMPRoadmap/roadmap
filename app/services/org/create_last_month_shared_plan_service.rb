# frozen_string_literal: true

#import statements fix Circular dependancy errors due to threading
import OrgDateRangeable
import StatSharedPlan
import StatSharedPlan::CreateOrUpdate
import User
import Plan
import Role

class Org

  class CreateLastMonthSharedPlanService

    class << self

      def call(org = nil, threads: 0)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org|
          months = OrgDateRangeable.split_months_from_creation(org)
          last = months.last
          if last.present?
            StatSharedPlan::CreateOrUpdate.do(
              start_date: last[:start_date],
              end_date: last[:end_date],
              org: org
            )
            StatSharedPlan::CreateOrUpdate.do(
              start_date: last[:start_date],
              end_date: last[:end_date],
              org: org,
              filtered: true
            )
          end
        end
      end

    end

  end

end
