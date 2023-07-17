# frozen_string_literal: true

# == Schema Information
#
# Table name: registry_orgs
#
#  id                     :integer          not null, primary key
#  org_id                 :bigint(8)
#  ror_id                 :string(255)
#  funder_id              :string(255)
#  name                   :string(255)
#  homepage               :string(255)
#  language               :string(255)
#  types                  :json
#  acronyms               :json
#  aliases                :json
#  country                :json
#  file_timestamp         :datetime
#  api_target             :string
#  api_auth_target        :string
#  api_guidance           :text
#  api_query_fields       :json
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_registry_orgs_on_ror_id          (ror_id)
#  index_registry_orgs_on_funddref_id     (fundref_id)
#  index_registry_orgs_on_name            (name)
#  index_registry_orgs_on_file_timestamp  (file_timestamp)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#
FactoryBot.define do
  factory :registry_org do
    name            { Faker::Company.unique.name }
    ror_id          { Faker::Internet.unique.url }
    fundref_id      { Faker::Internet.unique.url }
    home_page       { Faker::Internet.unique.url }
    language        { Faker::ProgrammingLanguage.name }
    types           { [Faker::Music::PearlJam.song, Faker::Music::GratefulDead.song] }
    acronyms        { [Faker::Movies::StarWars.character, Faker::Movies::StarWars.character] }
    aliases         { [Faker::Movies::Hobbit.character, Faker::Movies::Hobbit.character] }
    country         { [Faker::Movies::StarWars.planet, Faker::Movies::StarWars.planet] }
    file_timestamp  { 1.day.ago }
  end
end
