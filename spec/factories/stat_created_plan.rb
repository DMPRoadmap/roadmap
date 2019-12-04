FactoryBot.define do
  factory :stat_created_plan do
    date { Date.today }
    org { create(:org) }
    count { Faker::Number.number(digits: 10) }
  end
end
