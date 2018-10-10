class Org
  class CreateJoinedUserService
    class << self
      def call(org = nil)
        orgs = org.nil? ? ::Org.all : [org]
        orgs.each do |org|
          OrgDateRangeable.split_months_from_creation(org) do |start_date, end_date|
            create_count_for_date(start_date: start_date, end_date: end_date, org: org)
          end
        end
      end

      private

      def count_users(start_date: , end_date: , org_id: )
        User.where('created_at >= ? AND created_at <= ? AND org_id = ?', start_date, end_date, org_id).count
      end

      def create_count_for_date(start_date:, end_date:, org:)
        count = count_users(start_date: start_date, end_date: end_date, org_id: org.id)
        ::StatJoinedUser.create(date: end_date.to_date, count: count, org_id: org.id)
      end
    end
  end
end
