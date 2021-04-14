# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                :bigint           not null, primary key
#  callback_uri      :string
#  identifiable_type :string
#  subscription_type :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  identifiable_id   :bigint
#  plan_id           :bigint
#  last_notified     :datetime
#
# Indexes
#
#  index_subscribers_on_identifiable_and_plan_id  (identifiable_id,identifiable_type,plan_id)
#  index_subscribers_on_plan_id                   (plan_id)
#
FactoryBot.define do
  factory :subscription do
=begin
    trait :api_client do
      association :identifiable, factory: :api_client
    end
    trait :org do
      association :identifiable, factory: :org
    end

    trait :on_all do
      on_update { true }
      on_destroy { true }
    end
    trait :on_update do
      on_update { true }
      on_destroy { false }
    end
    trait :on_destroy do
      on_update { false }
      on_destroy { true }
    end
=end
  end
end
