# frozen_string_literal: true

# statements fix Circular dependancy errors due to threading
# see: https://github.com/grosser/parallel#nameerror-uninitialized-constant
OrgDateRangeable.class
StatJoinedUser.class
StatJoinedUser::CreateOrUpdate.class
User.class

class Org

  class CreateJoinedUserService

    class << self

      def call(org = nil, threads: 0)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org_obj|
          OrgDateRangeable.split_months_from_creation(org_obj) do |start_date, end_date|
            StatJoinedUser::CreateOrUpdate.do(
              start_date: start_date,
              end_date: end_date,
              org: org_obj
            )
          end
        end
        # pp StatJoinedUser.where.not(count: 0)
      end

    end

  end

end
