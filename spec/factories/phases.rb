# == Schema Information
#
# Table name: phases
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  number      :integer
#  template_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  slug        :string
#  modifiable  :boolean
#

FactoryBot.define do
  factory :phase do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    sequence(:number)
    template
    modifiable true
  end
end
