# frozen_string_literal: true

class StatJoinedUser

  class CreateOrUpdate

    class << self

      def do(start_date:, end_date:, org:)
        count = count_users(start_date: start_date, end_date: end_date, org_id: org.id)
        attrs = { date: end_date.to_date, count: count, org_id: org.id }

        stat_joined_user = StatJoinedUser.find_by(
          date: attrs[:date],
          org_id: attrs[:org_id]
        )

        if stat_joined_user.present?
          stat_joined_user.update(attrs)
        else
          StatJoinedUser.create(attrs)
        end
      end

      private

      def count_users(start_date:, end_date:, org_id:)
        User.where(created_at: start_date..end_date, org_id: org_id).count
      end

    end

  end

end
