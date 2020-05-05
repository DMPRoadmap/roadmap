FactoryBot.define do
  factory :stat_joined_user do
    date { Date.today }
    org { create(:org) }
    count { Faker::Number.number(digits: 10) }
  end
end
