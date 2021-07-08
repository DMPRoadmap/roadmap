# == Schema Information
#
# Table name: metadata_standards
#
#  id                  :bigint(8)        not null, primary key
#  description         :text(65535)
#  locations           :json
#  related_entities    :json
#  title               :string(255)
#  uri                 :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  rdamsc_id           :string(255)
#
FactoryBot.define do
  factory :metadata_standard do
    description { Faker::Lorem.paragraph }
    locations {
      [
        { type: %w[website document RDFS].sample, url: Faker::Internet.unique.url },
        { type: %w[website document RDFS].sample, url: Faker::Internet.unique.url }
      ]
    }
    related_entities {
      [
        { role: %w[user tool child scheme].sample, id: "msc:#{Faker::Number.unique.number(digits: 2)}" },
        { role: %w[user tool child scheme].sample, id: "msc:#{Faker::Number.unique.number(digits: 2)}" }
      ]
     }
    title { Faker::Lorem.unique.sentence }
    uri { Faker::Internet.unique.url }
    rdamsc_id { "msc:#{Faker::Number.unique.number(digits: 2)}" }
  end
end
