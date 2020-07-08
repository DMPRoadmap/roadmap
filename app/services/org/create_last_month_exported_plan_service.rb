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

  class CreateLastMonthExportedPlanService

    class << self

      def call(org = nil, threads: 0)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org|
          months = OrgDateRangeable.split_months_from_creation(org)
          last = months.last
          if last.present?
            StatExportedPlan::CreateOrUpdate.do(
              start_date: last[:start_date],
              end_date: last[:end_date],
              org: org
            )
            StatExportedPlan::CreateOrUpdate.do(
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
