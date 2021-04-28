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
    callback_uri        { Faker::Internet.unique.url }
    last_notified       { Time.now - 1.days }

    trait :for_updates do
      subscription_types { "updates" }
    end

    trait :for_creations do
      visibility { "creations" }
    end

    trait :for_deletions do
      visibility { "deletions" }
    end

  end
end
