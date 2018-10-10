class Org
  class TotalCountJoinedUserService
    class << self
      def call(org = nil)
        return for_orgs unless org.present?
        for_org(org)
      end

      private

      def for_orgs
        result = ::StatJoinedUser.includes(:org).select(:"orgs.name", :count).group(:"orgs.name").sum(:count)
        result.each_pair.map do |pair|
          build_model(org_name: pair[0], count: pair[1].to_i)
        end
      end

      def for_org(org)
        result = ::StatJoinedUser.where(org: org).sum(:count)
        build_model(org_name: org.name, count: result)
      end

      def build_model(org_name: , count: )
        { org_name: org_name, count: count }
      end
    end
  end
end
