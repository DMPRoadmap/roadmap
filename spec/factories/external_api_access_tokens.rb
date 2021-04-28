# frozen_string_literal: true

# == Schema Information
#
# Table name: external_api_access_tokens
#
#  id                     :integer          not null, primary key
#  user_id                :integer          not null
#  external_service_name  :string
#  access_token           :string
#  refresh_token          :string
#  expires_at             :datetime
#  revoked_at             :datetime
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_external_api_access_tokens_on_external_service_name  (external_service_name)
#  index_external_api_access_tokens_on_expires_at             (expires_at)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)

FactoryBot.define do
  factory :external_api_access_token do
    external_service_name { Faker::Lorem.unique.word.downcase }
    access_token          { SecureRandom.uuid }
    refresh_token         { SecureRandom.uuid }
    expires_at            { Time.now + 1.hour }
  end
end
