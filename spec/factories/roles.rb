# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  plan_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  access     :integer          default("0"), not null
#  active     :boolean          default("false")
#
# Indexes
#
#  roles_plan_id_idx  (plan_id)
#  roles_user_id_idx  (user_id)
#

FactoryBot.define do
  factory :role do
    user
    plan
    access { 0 }
    active { true }
    trait :active do
      active { true }
    end
    trait :inactive do
      active { false }
    end

    trait :creator do
      creator { true }
      administrator { true }
      editor { true }
      commenter { true }
    end
    trait :administrator do
      administrator { true }
      editor { true }
      commenter { true }
    end
    trait :editor do
      editor { true }
      commenter { true }
    end
    trait :commenter do
      commenter { true }
    end
    trait :reviewer do
      reviewer { true }
      commenter { true }
    end
  end
end
