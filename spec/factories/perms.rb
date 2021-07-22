# frozen_string_literal: true

# == Schema Information
#
# Table name: perms
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :perm do
    name { Faker::Company.catch_phrase }

    trait :add_organisations do
      name { "add_organisations" }
      initialize_with { Perm.find_or_create_by(name: name) }
    end

    trait :change_org_affiliation do
      name { "change_org_affiliation" }
      initialize_with { Perm.find_or_create_by(name: name) }
    end

    trait :grant_permissions do
      name { "grant_permissions" }
      initialize_with { Perm.find_or_create_by(name: name) }
    end

    trait :modify_templates do
      name { "modify_templates" }
      initialize_with { Perm.find_or_create_by(name: name) }
    end

    trait :modify_guidance do
      name { "modify_guidance" }
      initialize_with { Perm.find_or_create_by(name: name) }
    end

    trait :use_api do
      name { "use_api" }
      initialize_with { Perm.find_or_create_by(name: name) }
    end

    trait :change_org_details do
      name { "change_org_details" }
      initialize_with { Perm.find_or_create_by(name: name) }
    end

    trait :grant_api_to_orgs do
      name { "grant_api_to_orgs" }
      initialize_with { Perm.find_or_create_by(name: name) }
    end

    trait :review_org_plans do
      name { "review_org_plans" }
      initialize_with { Perm.find_or_create_by(name: name) }
    end
  end
end
