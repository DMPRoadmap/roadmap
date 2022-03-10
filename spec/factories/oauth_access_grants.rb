# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_access_grants
#
#  id                     :integer      not null, primary key
#  resource_owner_id      :integer      not null
#  application_id         :integer      not null
#  token                  :string       not null
#  expires_in             :integer
#  revoked_at             :datetime
#  created_at             :datetime     not null
#  scopes                 :string       not null
#
# Indexes
#
#  index_oauth_access_grants_on_token  (token)
#
# Foreign Keys
#
#  fk_rails_...  (resource_owner_id => users.id)
#  fk_rails_...  (application_id => oauth_applications.id)

FactoryBot.define do
  factory :oauth_access_grant, class: 'doorkeeper/access_grant' do
    token         { SecureRandom.uuid }
    expires_in    { Faker::Number.number(digits: 8) }
    scopes        { Doorkeeper.config.default_scopes + Doorkeeper.config.optional_scopes }

    trait :revoked do
      revoked_at { Time.now - 2.hours }
    end
  end
end
