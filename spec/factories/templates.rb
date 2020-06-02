# == Schema Information
#
# Table name: templates
#
#  id               :integer          not null, primary key
#  title            :string
#  description      :text
#  published        :boolean
#  org_id           :integer
#  locale           :string
#  is_default       :boolean
#  created_at       :datetime
#  updated_at       :datetime
#  version          :integer
#  visibility       :integer
#  customization_of :integer
#  family_id        :integer
#  archived         :boolean
#  links            :text
#
# Indexes
#
#  templates_customization_of_version_org_id_key  (customization_of,version,org_id) UNIQUE
#  templates_family_id_version_key                (family_id,version) UNIQUE
#  templates_org_id_idx                           (org_id)
#

FactoryBot.define do
  factory :template do
    org
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    locale { "en_GB" }
    is_default { false }
    published { false }
    archived { false }
    sequence(:version)
    family_id { rand(10_000) }

    trait :publicly_visible do
      after(:create) do |template|
        template.update(visibility: Template.visibilities[:publicly_visible])
      end
    end

    trait :organisationally_visible do
      after(:create) do |template|
        template.update(visibility: Template.visibilities[:organisationally_visible])
      end
    end

    trait :archived do
      archived { true }
    end

    trait :default do
      is_default { true }
    end

    trait :published do
      published { true }
    end

    trait :unpublished do
      published { false }
    end

    transient do
      phases { 0 }
      sections { 0 }
      questions { 0 }
    end

    after(:create) do |template, evaluator|
      create_list(:phase, evaluator.phases, template: template, sections: evaluator.sections, questions: evaluator.questions)
    end

  end
end
