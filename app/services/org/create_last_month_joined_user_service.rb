# frozen_string_literal: true

# statements fix Circular dependancy errors due to threading
# see: https://github.com/grosser/parallel#nameerror-uninitialized-constant
OrgDateRangeable.class
StatJoinedUser.class
StatJoinedUser::CreateOrUpdate.class
User.class

class Org

  class CreateLastMonthJoinedUserService

    class << self

      def call(org = nil, threads: 0)
        orgs = org.nil? ? ::Org.all : [org]

        Parallel.each(orgs, in_threads: threads) do |org_obj|
          months = OrgDateRangeable.split_months_from_creation(org_obj)
          last = months.last
          next unless last.present?

          StatJoinedUser::CreateOrUpdate.do(
            start_date: last[:start_date],
            end_date: last[:end_date],
            org: org_obj
          )
        end
      end

    end

  end

end
