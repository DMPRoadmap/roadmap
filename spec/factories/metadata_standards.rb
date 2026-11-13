# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata_standards
#
#  id               :bigint(8)        not null, primary key
#  description      :text
#  locations        :json
#  related_entities :json
#  title            :string
#  uri              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  rdamsc_id        :string
#
FactoryBot.define do
  factory :metadata_standard do
    description { Faker::Lorem.paragraph }
    locations do
      [
        { type: %w[website document RDFS].sample, url: Faker::Internet.unique.url },
        { type: %w[website document RDFS].sample, url: Faker::Internet.unique.url }
      ]
    end
    related_entities do
      [
        {
          role: %w[user tool child scheme].sample,
          id: "msc:#{Faker::Number.unique.number(digits: 2)}"
        },
        {
          role: %w[user tool child scheme].sample,
          id: "msc:#{Faker::Number.unique.number(digits: 2)}"
        }
      ]
    end
    title { Faker::Lorem.unique.sentence }
    uri { Faker::Internet.unique.url }
    rdamsc_id { "msc:#{Faker::Number.unique.number(digits: 2)}" }
  end
end
