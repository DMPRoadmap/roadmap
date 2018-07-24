# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  plan_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  access     :integer          default(0), not null
#  active     :boolean          default(TRUE)
#

FactoryBot.define do
  factory :role do
    user
    plan
    access 0
    trait :active do
      active true
    end
    trait :inactive do
      active false
    end
    trait :creator do
      creator true
    end
    trait :administrator do
      administrator true
    end
    trait :editor do
      editor true
    end
    trait :commenter do
      commenter true
    end
    trait :reviewer do
      reviewer true
    end
  end
end
