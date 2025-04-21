# frozen_string_literal: true

# statements fix Circular dependency errors due to threading
# see: https://github.com/grosser/parallel#nameerror-uninitialized-constant
OrgDateRangeable.class
StatSharedPlan.class
StatSharedPlan::CreateOrUpdate.class
User.class
Plan.class
Role.class

# Org usage --- TODO: This should likely be a module
class Org
  # Usage for Nbr of shared plans
  class CreateSharedPlanService
    class << self
      def call(org = nil, threads: 0)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org_obj|
          OrgDateRangeable.split_months_from_creation(org_obj) do |start_date, end_date|
            StatSharedPlan::CreateOrUpdate.do(
              start_date: start_date,
              end_date: end_date,
              org: org_obj
            )
            StatSharedPlan::CreateOrUpdate.do(
              start_date: start_date,
              end_date: end_date,
              org: org_obj,
              filtered: true
            )
          end
        end
      end
    end
  end
end
