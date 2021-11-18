# frozen_string_literal: true

#import statements fix Circular dependancy errors due to threading
import OrgDateRangeable
import StatCreatedPlan
import StatCreatedPlan::CreateOrUpdate
import Role
import User
import Plan
import Perm
import Template


class Org

  class CreateLastMonthCreatedPlanService

    class << self

      def call(org = nil, threads: 0)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org|
          months = OrgDateRangeable.split_months_from_creation(org)
          last = months.last
          if last.present?
            StatCreatedPlan::CreateOrUpdate.do(
              start_date: last[:start_date],
              end_date: last[:end_date],
              org: org
            )
            StatCreatedPlan::CreateOrUpdate.do(
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
