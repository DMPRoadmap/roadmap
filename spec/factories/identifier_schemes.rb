# == Schema Information
#
# Table name: identifier_schemes
#
#  id               :integer          not null, primary key
#  name             :string
#  description      :string
#  active           :boolean
#  created_at       :datetime
#  updated_at       :datetime
#  logo_url         :text
#  user_landing_url :text
#

FactoryBot.define do
  factory :identifier_scheme do
    name { Faker::Company.unique.name }
    description { Faker::StarWars.quote }
    logo_url { Faker::Internet.url }
    user_landing_url { Faker::Internet.url }
    active true
  end
end
