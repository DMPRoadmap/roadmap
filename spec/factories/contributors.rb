# frozen_string_literal: true

# == Schema Information
#
# Table name: contributors
#
#  id           :integer          not null, primary key
#  firstname    :string
#  surname      :string
#  email        :string
#  phone        :string
#  org_id       :integer
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_contributors_on_id      (id)
#  index_contributors_on_email   (email)
#  index_contributors_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)

FactoryBot.define do
  factory :contributor do
    org
    firstname { Faker::Movies::StarWars.character.split.first }
    surname { Faker::Movies::StarWars.character.split.last }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
  end
end
