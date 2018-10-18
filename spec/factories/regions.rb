# == Schema Information
#
# Table name: regions
#
#  id              :integer          not null, primary key
#  abbreviation    :string
#  description     :string
#  name            :string
#  super_region_id :integer
#

FactoryBot.define do
  factory :region do
    name { Faker::Address.country }
    abbreviation { SecureRandom.hex(2)  }
    description { Faker::Lorem.sentence }
  end
end
