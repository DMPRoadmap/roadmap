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

  class CreateCreatedPlanService

    class << self

      def call(org = nil, threads: 0)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org|
          OrgDateRangeable.split_months_from_creation(org) do |start_date, end_date|
            StatCreatedPlan::CreateOrUpdate.do(
              start_date: start_date,
              end_date: end_date,
              org: org
            )
            # 2nd call to pull stats on just 'real' plans
            StatCreatedPlan::CreateOrUpdate.do(
              start_date: start_date,
              end_date: end_date,
              org: org,
              filtered: true
            )
          end
        end
      end

    end

  end

end
