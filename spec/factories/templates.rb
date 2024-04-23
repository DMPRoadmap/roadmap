# frozen_string_literal: true

# == Schema Information
#
# Table name: templates
#
#  id               :integer          not null, primary key
#  archived         :boolean
#  context          :integer          default("research_project"), not null
#  customization_of :integer
#  description      :text
#  is_default       :boolean
#  is_recommended   :boolean          default(FALSE)
#  links            :text
#  locale           :string
#  published        :boolean
#  title            :string
#  type             :integer          default("classic"), not null
#  version          :integer
#  visibility       :integer
#  created_at       :datetime
#  updated_at       :datetime
#  family_id        :integer
#  org_id           :integer
#
# Indexes
#
#  templates_customization_of_version_org_id_key  (customization_of,version,org_id) UNIQUE
#  templates_family_id_version_key                (family_id,version) UNIQUE
#  templates_org_id_idx                           (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#

FactoryBot.define do
  factory :template do
    org
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    locale { 'en_GB' }
    is_default { false }
    published { false }
    archived { false }
    sequence(:version)

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
      create_list(:phase, evaluator.phases, template: template,
                                            sections: evaluator.sections,
                                            questions: evaluator.questions)
    end
  end
end
