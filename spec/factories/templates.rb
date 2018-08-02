# == Schema Information
#
# Table name: templates
#
#  id               :integer          not null, primary key
#  archived         :boolean
#  customization_of :integer
#  description      :text
#  is_default       :boolean
#  links            :text
#  locale           :string
#  published        :boolean
#  title            :string
#  version          :integer
#  visibility       :integer
#  created_at       :datetime
#  updated_at       :datetime
#  family_id        :integer
#  org_id           :integer
#
# Indexes
#
#  index_templates_on_customization_of_and_version_and_org_id  (customization_of,version,org_id) UNIQUE
#  index_templates_on_family_id                                (family_id)
#  index_templates_on_family_id_and_version                    (family_id,version) UNIQUE
#  index_templates_on_org_id                                   (org_id)
#  template_organisation_dmptemplate_index                     (org_id,family_id)
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
    locale { "en_GB" }
  end
end
