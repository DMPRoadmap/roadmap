# frozen_string_literal: true

# == Schema Information
#
# Table name: api_logs
#
#  id                   :integer          not null, primary key
#  oauth_application_id :integer          not null
#  change_type          :integer          not null
#  activity             :text             not null
#  logable_id           :integer          not null
#  logable_type         :string           not null
#
# Indexes
#
#  index_api_logs_on_logable_and_change_type (logable_id, logable_type, change_type)
#
# Foreign Keys
#
#  fk_rails_...  (oauth_application_id => oauth_applications.id)
#
FactoryBot.define do
  factory :api_log do
    association :oauth_application, factory: :api_client
    for_plan

    change_type { ApiLog.change_types.keys.sample }
    activity { Faker::Lorem.paragraph }

    trait :for_plan do
      association :logable, factory: :plan
    end

    trait :for_related_identifier do
      association :logable, factory: :related_identifier
    end
  end
end