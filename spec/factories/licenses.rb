# frozen_string_literal: true

# == Schema Information
#
# Table name: licenses
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  identifier   :string
#  url          :string
#  osi_approved :boolean          default: false
#  deprecated   :boolean          default: false
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_licenses_on_identifier               (name)
#  index_licenses_on_url                      (url)
#  index_licenses_on_identifier_and_criteria  (identifier, osi_approved, deprecated)
#
FactoryBot.define do
  factory :license do
    name          { Faker::Lorem.sentence }
    identifier    { Faker::Music::PearlJam.unique.song.upcase }
    url           { Faker::Internet.unique.url}
    osi_approved  { [true, false].sample }
    deprecated    { [true, false].sample }
  end
end
