# frozen_string_literal: true

# == Schema Information
#
# Table name: external_api_access_tokens
#
#  id                    :bigint(8)        not null, primary key
#  access_token          :string(255)      not null
#  expires_at            :datetime
#  external_service_name :string(255)      not null
#  refresh_token         :string(255)
#  revoked_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :bigint(8)        not null
#
# Indexes
#
#  index_external_api_access_tokens_on_expires_at             (expires_at)
#  index_external_api_access_tokens_on_external_service_name  (external_service_name)
#  index_external_api_access_tokens_on_user_id                (user_id)
#  index_external_tokens_on_user_and_service                  (user_id,external_service_name)
#

FactoryBot.define do
  factory :external_api_access_token do
    external_service_name { Faker::Lorem.unique.word.downcase }
    access_token          { SecureRandom.uuid }
    refresh_token         { SecureRandom.uuid }
    expires_at            { Time.now + 1.hour }
  end
end
