# frozen_string_literal: true

class Org

  class CreateLastMonthExportedPlanService

    class << self

      def call(org = nil)
        orgs = org.nil? ? Org.all : [org]
        orgs.each do |org|
          months = OrgDateRangeable.split_months_from_creation(org)
          last = months.last
          if last.present?
            StatExportedPlan::CreateOrUpdate.do(
              start_date: last[:start_date],
              end_date: last[:end_date],
              org: org
            )
          end
        end
      end

    end

  end

end
