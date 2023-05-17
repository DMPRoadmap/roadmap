# frozen_string_literal: true

# == Schema Information
#
# Table name: orgs
#
#  id                     :integer          not null, primary key
#  abbreviation           :string
#  contact_email          :string
#  contact_name           :string
#  feedback_msg           :text
#  feedback_enabled       :boolean          default(FALSE)
#  is_other               :boolean          default(FALSE), not null
#  links                  :text(65535)
#  logo_name              :string(255)
#  logo_uid               :string(255)
#  managed                :boolean          default(FALSE), not null
#  name                   :string(255)
#  org_type               :integer          default(0), not null
#  target_url             :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  language_id            :integer
#  region_id              :integer
#
# Indexes
#
#  fk_rails_5640112cab  (language_id)
#  fk_rails_5a6adf6bab  (region_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (region_id => regions.id)
#

FactoryBot.define do
  factory :org do
    name { Faker::Company.unique.name }
    links { { 'org' => [] } }
    abbreviation { SecureRandom.hex(6) }
    feedback_enabled { false }
    region { Region.first || create(:region) }
    language { Language.default }
    is_other { false }
    contact_email { Faker::Internet.email }
    contact_name { Faker::Name.name }
    managed { true }
    api_create_plan_email_subject { Faker::Lorem.sentence }
    api_create_plan_email_body { Faker::Lorem.paragraph }

    trait :institution do
      institution { true }
    end
    trait :funder do
      funder { true }
    end
    trait :organisation do
      organisation { true }
    end
    trait :research_institute do
      research_institute { true }
    end
    trait :project do
      project { true }
    end
    trait :school do
      school { true }
    end

    transient do
      templates { 0 }
      plans { 0 }
    end

    after :create do |org, evaluator|
      create_list(:template, evaluator.templates, :published, org: org)
      create_list(:plan, evaluator.plans)
    end

    # ----------------------------------------------------
    # start DMPTool customization
    # ----------------------------------------------------
    trait :shibbolized do
      after :create do |org, _evaluator|
        scheme = IdentifierScheme.find_or_create_by(name: 'shibboleth')
        create(:identifier, identifiable: org, identifier_scheme: scheme,
                            value: SecureRandom.hex(4))
      end
    end
    # ----------------------------------------------------
    # end DMPTool customization
    # ----------------------------------------------------
  end
end
