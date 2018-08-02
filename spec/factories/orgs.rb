# == Schema Information
#
# Table name: orgs
#
#  id                     :integer          not null, primary key
#  abbreviation           :string
#  banner_text            :text
#  contact_email          :string
#  contact_name           :string
#  feedback_email_msg     :text
#  feedback_email_subject :string
#  feedback_enabled       :boolean          default(FALSE)
#  is_other               :boolean
#  links                  :text
#  logo_file_name         :string
#  logo_name              :string
#  logo_uid               :string
#  name                   :string
#  org_type               :integer          default(0), not null
#  sort_name              :string
#  target_url             :string
#  wayfless_entity        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  language_id            :integer
#  parent_id              :integer
#  region_id              :integer
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
    abbreviation { self.name[0..10] }
    feedback_enabled false
    region { Region.first || create(:region) }
    language { Language.first || create(:language) }
    is_other false
  end
end
