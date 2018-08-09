# == Schema Information
#
# Table name: themes
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  locale      :string
#

FactoryBot.define do
  factory :theme do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    locale "en_GB"
  end
end
