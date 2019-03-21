# == Schema Information
#
# Table name: themes
#
#  id          :integer          not null, primary key
#  description :text
#  locale      :string(510)
#  slug        :string(510)
#  title       :string(510)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :theme do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    locale { "en_GB" }
  end
end
