# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  description  :text
#  url          :string
#  contact      :string
#  info         :json
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_repositories_on_name      (name)
#  index_repositories_on_url       (url)
#
FactoryBot.define do
    factory :repository do
      name { Faker::Music::PearlJam.song }
      description { Faker::Lorem.paragraph }
      url { Faker::Internet.url }
      contact { Faker::Internet.email }
      info { 
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
      } 
    end
  end
  