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
#  links            :text             default({"funder"=>[], "sample_plan"=>[]})
#

FactoryBot.define do
  factory :template do
    org
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    locale { "en_GB" }
  end
end
