# frozen_string_literal: true

# == Schema Information
#
# Table name: api_clients
#
#  id            :integer          not null, primary key
#  client_secret :string           not null
#  contact_email :string           not null
#  contact_name  :string
#  description   :string
#  homepage      :string
#  last_access   :datetime
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :string           not null
#  org_id        :integer
#
# Indexes
#
#  index_api_clients_on_name  (name)
#

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
