# == Schema Information
#
# Table name: regions
#
#  id              :integer          not null, primary key
#  abbreviation    :string(510)
#  description     :string(510)
#  name            :string(510)
#  super_region_id :integer
#

FactoryBot.define do
  factory :region do
    name { Faker::Address.country }
    abbreviation { SecureRandom.hex(2)  }
    description { Faker::Lorem.sentence }
  end
end
