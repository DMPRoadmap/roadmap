# frozen_string_literal: true

# == Schema Information
#
# Table name: templates
#
#  id               :integer          not null, primary key
#  archived         :boolean
#  customization_of :integer
#  description      :text(65535)
#  is_default       :boolean
#  links            :text(65535)
#  locale           :string(255)
#  published        :boolean
#  title            :string(255)
#  version          :integer
#  visibility       :integer
#  created_at       :datetime
#  updated_at       :datetime
#  family_id        :integer
#  org_id           :integer
#  enable_research_outputs           :boolean
#  user_guidance_output_types        :string(255)
#  user_guidance_repositories        :string(255)
#  user_guidance_metadata_standards  :string(255)
#  user_guidance_licenses            :string(255)
#  customize_output_types            :boolean
#  customize_repositories            :boolean
#  customize_metadata_standards      :boolean
#  customize_licenses                :boolean
#
# Indexes
#
#  index_templates_on_family_id              (family_id)
#  index_templates_on_family_id_and_version  (family_id,version) UNIQUE
#  index_templates_on_org_id                 (org_id)
#  template_organisation_dmptemplate_index   (org_id,family_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#

FactoryBot.define do
  factory :template do
    org
    title { Faker::Lorem.unique.sentence }
    description { Faker::Lorem.paragraph }
    locale { 'en_GB' }
    is_default { false }
    published { false }
    archived { false }
    enable_research_outputs { true }
    customize_output_types { false }
    customize_repositories { false }
    customize_metadata_standards { false }
    customize_licenses { false }
    email_subject { Faker::Lorem.sentence }
    email_body { Faker::Lorem.paragraph }
    user_guidance_output_types { Faker::Lorem.paragraph }
    user_guidance_repositories { Faker::Lorem.paragraph }
    user_guidance_metadata_standards { Faker::Lorem.paragraph }
    user_guidance_licenses { Faker::Lorem.paragraph }

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
