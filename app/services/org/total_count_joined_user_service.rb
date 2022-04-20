# frozen_string_literal: true

<<<<<<< HEAD
class Org

  class TotalCountJoinedUserService

    class << self

=======
# Org usage --- TODO: This should likely be a module
class Org
  # Usage - total nbr of created users
  class TotalCountJoinedUserService
    class << self
>>>>>>> upstream/master
      def call(org = nil, filtered: false)
        return for_orgs(filtered) unless org.present?

        for_org(org, filtered)
      end

      private

      def for_orgs(filtered)
        result = ::StatJoinedUser
                 .where(filtered: filtered)
                 .includes(:org)
<<<<<<< HEAD
                 .select(:"orgs.name", :count)
                 .group(:"orgs.name")
=======
                 .select(:'orgs.name', :count)
                 .group(:'orgs.name')
>>>>>>> upstream/master
                 .sum(:count)
        result.each_pair.map do |pair|
          build_model(org_name: pair[0], count: pair[1].to_i)
        end
      end

      def for_org(org, filtered)
        result = ::StatJoinedUser.where(org: org, filtered: filtered).sum(:count)
        build_model(org_name: org.name, count: result)
      end

      def build_model(org_name:, count:)
        { org_name: org_name, count: count }
      end
<<<<<<< HEAD

    end

  end

=======
    end
  end
>>>>>>> upstream/master
end
