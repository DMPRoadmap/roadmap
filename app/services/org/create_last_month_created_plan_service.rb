# frozen_string_literal: true

class Org

  class CreateLastMonthCreatedPlanService

    class << self

      def call(org = nil)
        orgs = org.nil? ? Org.all : [org]

        orgs.each do |org|
          months = OrgDateRangeable.split_months_from_creation(org)
          last = months.last
          if last.present?
            StatCreatedPlan::CreateOrUpdate.do(
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
