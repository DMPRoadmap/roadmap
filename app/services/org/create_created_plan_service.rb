# frozen_string_literal: true

import Process
# need to explicitly import to avoid circular dependancies
import OrgDateRangeable
import StatCreatedPlan::CreateOrUpdate

class Org

  class CreateCreatedPlanService

    class << self

      def call(org = nil)
        orgs = org.nil? ? Org.all : [org]
        threads = []
        orgs.each do |org|
          pp "Running #{org.name}"
          # ensure the number of running threads don't exceed our db connection pool
          if threads.length == 4
            # rejoin and remove the longest-running thread
            threads.first.join
            threads.shift
          end
          t = Process.fork do
            OrgDateRangeable.split_months_from_creation(org) do |start_date, end_date|
              StatCreatedPlan::CreateOrUpdate.do(
                start_date: start_date,
                end_date: end_date,
                org: org
              )
            end
          end
        end
        Process.waitall

      end

    end

  end

end
