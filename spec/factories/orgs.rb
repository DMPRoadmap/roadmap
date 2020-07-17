# frozen_string_literal: true

# == Schema Information
#
# Table name: orgs
#
#  id                     :integer          not null, primary key
#  abbreviation           :string
#  contact_email          :string
#  contact_name           :string
#  feedback_email_msg     :text
#  feedback_email_subject :string
#  feedback_enabled       :boolean          default(FALSE)
#  is_other               :boolean          default(FALSE), not null
#  links                  :text
#  logo_name              :string
#  logo_uid               :string
#  managed                :boolean          default(FALSE), not null
#  name                   :string
#  org_type               :integer          default(0), not null
#  sort_name              :string
#  target_url             :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  language_id            :integer
#
# Indexes
#
#  fk_rails_5640112cab  (language_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#

FactoryBot.define do
  factory :org do
    name { Faker::Company.unique.name }
    links { { "org" => [] } }
    abbreviation { SecureRandom.hex(4) }
    feedback_enabled { false }
    region { Region.first || create(:region) }
    language { Language.default }
    is_other { false }
    contact_email { Faker::Internet.safe_email }
    contact_name { Faker::Name.name }
    managed { true }
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
  end
end
