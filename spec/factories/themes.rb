# == Schema Information
#
# Table name: themes
#
#  id          :integer          not null, primary key
#  description :text(65535)
#  locale      :string(255)
#  title       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :theme do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    locale "en_GB"
  end
end
