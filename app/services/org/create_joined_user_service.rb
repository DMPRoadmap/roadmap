# frozen_string_literal: true

#import statements fix Circular dependancy errors due to threading
import OrgDateRangeable
import StatJoinedUser
import StatJoinedUser::CreateOrUpdate
import User

class Org

  class CreateJoinedUserService

    class << self

      def call(org = nil, threads: 0)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org|
          OrgDateRangeable.split_months_from_creation(org) do |start_date, end_date|
            StatJoinedUser::CreateOrUpdate.do(
              start_date: start_date,
              end_date: end_date,
              org: org
            )
          end
        end
        # pp StatJoinedUser.where.not(count: 0)
      end

    end

  end

end
