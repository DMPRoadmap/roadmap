# == Schema Information
#
# Table name: orgs
#
#  id                     :integer          not null, primary key
#  abbreviation           :string(255)
#  contact_email          :string(255)
#  contact_name           :string(255)
#  feedback_email_msg     :text(65535)
#  feedback_email_subject :string(255)
#  feedback_enabled       :boolean          default(FALSE)
#  is_other               :boolean          default(FALSE), not null
#  links                  :text(65535)
#  logo_name              :string(255)
#  logo_uid               :string(255)
#  name                   :string(255)
#  org_type               :integer          default(0), not null
#  sort_name              :string(255)
#  target_url             :string(255)
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
    links { { "org" => [] } }
    abbreviation { SecureRandom.hex(4) }
    feedback_enabled false
    region { Region.first || create(:region) }
    language { Language.first || create(:language) }
    is_other false
    contact_email { Faker::Internet.safe_email }
    trait :institution do
      institution true
    end
    trait :funder do
      funder true
    end
    trait :organisation do
      organisation true
    end
    trait :research_institute do
      research_institute true
    end
    trait :project do
      project true
    end
    trait :school do
      school true
    end

    transient do
      templates 0
    end

    after :create do |org, evaluator|
      create_list(:template, evaluator.templates, :published, org: org)
    end
  end
end


