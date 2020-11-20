# frozen_string_literal: true

# == Schema Information
#
# Table name: stats
#
#  id         :integer          not null, primary key
#  count      :bigint(8)        default(0)
#  date       :date             not null
#  details    :text
#  filtered   :boolean          default(FALSE)
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#

class StatSharedPlan < Stat

  class << self

    def to_csv(shared_plans)
      Stat.to_csv(shared_plans)
    end

  end

end
