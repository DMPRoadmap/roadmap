# == Schema Information
#
# Table name: orgs
#
#  id                     :integer          not null, primary key
#  name                   :string
#  abbreviation           :string
#  target_url             :string
#  wayfless_entity        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  parent_id              :integer
#  is_other               :boolean
#  sort_name              :string
#  banner_text            :text
#  logo_file_name         :string
#  region_id              :integer
#  language_id            :integer
#  logo_uid               :string
#  logo_name              :string
#  contact_email          :string
#  org_type               :integer          default(0), not null
#  links                  :text             default({"org"=>[]})
#  contact_name           :string
#  feedback_enabled       :boolean          default(FALSE)
#  feedback_email_subject :string
#  feedback_email_msg     :text
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


