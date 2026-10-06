# frozen_string_literal: true

# == Schema Information
#
# Table name: licenses
#
#  id           :bigint(8)        not null, primary key
#  deprecated   :boolean          default(FALSE)
#  identifier   :string           not null
#  name         :string           not null
#  osi_approved :boolean          default(FALSE)
#  uri          :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_license_on_identifier_and_criteria  (identifier,osi_approved,deprecated)
#  index_licenses_on_identifier              (identifier)
#  index_licenses_on_uri                     (uri)
#
FactoryBot.define do
  factory :license do
    name          { Faker::Lorem.sentence }
    identifier    { Faker::Music::PearlJam.unique.song.upcase }
    uri           { Faker::Internet.unique.url }
    osi_approved  { [true, false].sample }
    deprecated    { [true, false].sample }
  end
end
