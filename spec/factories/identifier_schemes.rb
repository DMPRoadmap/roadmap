# == Schema Information
#
# Table name: identifier_schemes
#
#  id               :integer          not null, primary key
#  active           :boolean
#  description      :string(255)
#  logo_url         :string(255)
#  name             :string(255)
#  user_landing_url :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

FactoryBot.define do
  factory :identifier_scheme do
    name { Faker::Company.unique.name[0..29] }
    description { Faker::StarWars.quote }
    logo_url { Faker::Internet.url }
    user_landing_url { Faker::Internet.url }
    active true
  end
end
