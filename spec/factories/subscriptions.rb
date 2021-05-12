# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                 :bigint           not null, primary key
#  plan_id            :bigint
#  subscription_types :integer          not null
#  callback_uri       :string
#  subscriber_id      :bigint
#  subscriber_type    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  last_notified      :datetime
#
# Indexes
#
#  index_subscribers_on_identifiable_and_plan_id  (identifiable_id,identifiable_type,plan_id)
#  index_subscribers_on_plan_id                   (plan_id)
#
FactoryBot.define do
  factory :subscription do
    callback_uri        { Faker::Internet.unique.url }
    last_notified       { Time.now - 1.days }
    for_updates

    association :subscriber, factory: :api_client

    trait :for_updates do
      subscription_types { "updates" }
    end

    trait :for_creations do
      subscription_types { "creations" }
    end

    trait :for_deletions do
      subscription_types { "deletions" }
    end

  end
end
