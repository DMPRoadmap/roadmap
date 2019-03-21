# frozen_string_literal: true

class Org

  class CreateCreatedPlanService

    class << self

      def call(org = nil)
        orgs = org.nil? ? Org.all : [org]

        orgs.each do |org|
          OrgDateRangeable.split_months_from_creation(org) do |start_date, end_date|
            StatCreatedPlan::CreateOrUpdate.do(
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
