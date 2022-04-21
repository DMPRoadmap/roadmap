# frozen_string_literal: true

# statements fix Circular dependancy errors due to threading
# see: https://github.com/grosser/parallel#nameerror-uninitialized-constant
OrgDateRangeable.class
StatSharedPlan.class
StatSharedPlan::CreateOrUpdate.class
User.class
Plan.class
Role.class

# Org usage --- TODO: This should likely be a module
class Org
  # Usage for Nbr of shared plans in the prior month
  class CreateLastMonthSharedPlanService
    class << self
      def call(org = nil, threads: 0)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org_obj|
          months = OrgDateRangeable.split_months_from_creation(org_obj)
          last = months.last
          next unless last.present?

          StatSharedPlan::CreateOrUpdate.do(
            start_date: last[:start_date],
            end_date: last[:end_date],
            org: org_obj
          )
          StatSharedPlan::CreateOrUpdate.do(
            start_date: last[:start_date],
            end_date: last[:end_date],
            org: org_obj,
            filtered: true
          )
        end
      end
    end
  end
end
