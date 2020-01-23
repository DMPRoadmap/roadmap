# frozen_string_literal: true

# == Schema Information
#
# Table name: identifiers
#
#  id                   :integer          not null, primary key
#  attrs                :text
#  value                :string           not null
#  created_at           :datetime
#  updated_at           :datetime
#  identifiable_id      :integer
#  identifiable_type    :string
#
# Foreign Keys
#
#  fk_rails_...  (identifier_scheme_id => identifier_schemes.id)
#

FactoryBot.define do
  factory :identifier do
    identifier_scheme
    for_user

    value { Faker::Lorem.word }
    attrs { {} }

    trait :for_plan do
      association :identifiable, factory: :plan
    end
    trait :for_org do
      association :identifiable, factory: :org
    end
    trait :for_user do
      association :identifiable, factory: :user
    end
  end
end
