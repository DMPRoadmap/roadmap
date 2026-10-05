# frozen_string_literal: true

# == Schema Information
#
# Table name: trackers
#
#  id         :integer          not null, primary key
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#
# Indexes
#
#  index_trackers_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#
FactoryBot.define do
  factory :tracker do
    org { nil }
    code { "UA-#{Faker::Number.number(digits: 5)}-#{Faker::Number.number(digits: 2)}" }
  end
end
