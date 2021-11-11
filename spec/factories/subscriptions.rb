# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                 :bigint(8)        not null, primary key
#  callback_uri       :string(255)
#  last_notified      :datetime
#  subscriber_type    :string(255)
#  subscription_types :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  plan_id            :bigint(8)
#  subscriber_id      :bigint(8)
#
# Indexes
#
#  index_subscribers_on_identifiable_and_plan_id  (subscriber_id,subscriber_type,plan_id)
#  index_subscriptions_on_plan_id                 (plan_id)
#
FactoryBot.define do
  factory :subscription do
    callback_uri        { Faker::Internet.unique.url }
    last_notified       { Time.now - 1.days }
    for_updates

    association :subscriber, factory: :api_client

    trait :for_updates do
      subscription_types { 'updates' }
    end

    trait :for_creations do
      subscription_types { 'creations' }
    end

    trait :for_deletions do
      subscription_types { 'deletions' }
    end
  end
end
