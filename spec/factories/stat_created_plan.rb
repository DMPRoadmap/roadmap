# frozen_string_literal: true

# == Schema Information
#
# Table name: stats
#
#  id         :integer          not null, primary key
#  count      :integer          default(0)
#  date       :date             not null
#  details    :text
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#

FactoryBot.define do
  factory :stat_created_plan do
    date { Date.today }
    org { create(:org) }
    count { Faker::Number.number(digits: 10) }
    details { "{\"by_template\":[]}" }
  end
end
