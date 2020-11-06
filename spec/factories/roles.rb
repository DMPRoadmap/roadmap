# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  access     :integer          default(0), not null
#  active     :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#  plan_id    :integer
#  user_id    :integer
#
# Indexes
#
#  index_roles_on_plan_id  (plan_id)
#  index_roles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (user_id => users.id)
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
