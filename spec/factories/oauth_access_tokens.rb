# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_access_tokens
#
#  id                     :integer      not null, primary key
#  resource_owner_id      :integer      not null
#  application_id         :integer      not null
#  token                  :string       not null
#  refresh_token          :string
#  expires_in             :integer
#  revoked_at             :datetime
#  created_at             :datetime     not null
#  scopes                 :string       not null
#  previous_refresh_token :string
#
# Indexes
#
#  index_oauth_access_tokens_on_token  (token)
#
# Foreign Keys
#
#  fk_rails_...  (resource_owner_id => users.id)
#  fk_rails_...  (application_id => oauth_applications.id)

FactoryBot.define do
  factory :oauth_access_token, class: 'doorkeeper/access_token' do
    token         { SecureRandom.uuid }
    refresh_token { SecureRandom.uuid }
    expires_in    { Faker::Number.number(digits: 8) }
    scopes        { Doorkeeper.config.default_scopes + Doorkeeper.config.optional_scopes }

    trait :revoked do
      revoked_at { 2.hours.ago }
    end
  end
end
