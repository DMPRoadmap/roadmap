# frozen_string_literal: true

# statements fix Circular dependancy errors due to threading
# see: https://github.com/grosser/parallel#nameerror-uninitialized-constant
OrgDateRangeable.class
StatExportedPlan.class
StatExportedPlan::CreateOrUpdate.class
Role.class
Plan.class
User.class
ExportedPlan.class

class Org

  class CreateExportedPlanService

    class << self

      def call(org = nil, threads: 0)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org_obj|
          OrgDateRangeable.split_months_from_creation(org_obj) do |start_date, end_date|
            StatExportedPlan::CreateOrUpdate.do(
              start_date: start_date,
              end_date: end_date,
              org: org_obj
            )
            StatExportedPlan::CreateOrUpdate.do(
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
