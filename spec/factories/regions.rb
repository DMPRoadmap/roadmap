# == Schema Information
#
# Table name: regions
#
#  id              :integer          not null, primary key
#  abbreviation    :string(255)
#  description     :string(255)
#  name            :string(255)
#  super_region_id :integer
#

FactoryBot.define do
  factory :region do
    name { Faker::Address.country }
    abbreviation { SecureRandom.hex(2)  }
    description { Faker::Lorem.sentence }
  end
end
