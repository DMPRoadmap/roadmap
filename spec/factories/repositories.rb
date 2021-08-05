# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id          :bigint           not null, primary key
#  contact     :string
#  description :text             not null
#  info        :json
#  name        :string           not null
#  homepage    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uri         :string           not null
#
# Indexes
#
#  index_repositories_on_name  (name)
#  index_repositories_on_url   (homepage)
#  index_repositories_on_url   (uri)
#
FactoryBot.define do
  factory :repository do
    name { Faker::Music::PearlJam.song }
    description { Faker::Lorem.paragraph }
    homepage { Faker::Internet.unique.url }
    uri { Faker::Internet.unique.url }
    contact { Faker::Internet.email }
    info do
      {
        types: [%w[disciplinary institutional other].sample],
        access: %w[closed open restricted].sample,
        keywords: [Faker::Lorem.word],
        policies: [{ url: Faker::Internet.url, name: Faker::Music::PearlJam.album }],
        subjects: ["#{Faker::Number.number(digits: 2)} #{Faker::Lorem.sentence}"],
        pid_system: %w[ARK DOI handle].sample,
        upload_types: [{ type: Faker::Lorem.word, restriction: Faker::Lorem.word }],
        provider_types: [%w[dataProvider serviceProvider].sample]
      }
    end
  end
end
