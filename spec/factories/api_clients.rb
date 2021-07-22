# frozen_string_literal: true

# == Schema Information
#
# Table name: api_clients
#
#  id             :integer          not null, primary key
#  name           :string,          not null
#  homepage       :string
#  contact_name   :string
#  contact_email  :string,          not null
#  client_id      :string,          not null
#  client_secret  :string,          not null
#  last_access    :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  org_id         :integer
#
# Indexes
#
#  index_api_clients_on_name     (name)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)

FactoryBot.define do
  factory :api_client do
    name { Faker::Lorem.unique.word }
    homepage { Faker::Internet.url }
    contact_name { Faker::Movies::StarWars.character }
    contact_email { Faker::Internet.email }
    client_id { SecureRandom.uuid }
    client_secret { SecureRandom.uuid }
  end
end
