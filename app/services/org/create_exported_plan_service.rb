# frozen_string_literal: true

#import statements fix Circular dependancy errors
import OrgDateRangeable
import StatExportedPlan
import StatExportedPlan::CreateOrUpdate
import Role
import Plan
import User
import ExportedPlan

class Org

  class CreateExportedPlanService

    class << self

      def call(org = nil, threads: 0)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org|
          OrgDateRangeable.split_months_from_creation(org) do |start_date, end_date|
            StatExportedPlan::CreateOrUpdate.do(
              start_date: start_date,
              end_date: end_date,
              org: org
            )
            StatExportedPlan::CreateOrUpdate.do(
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
