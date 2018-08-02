# == Schema Information
#
# Table name: sections
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  number      :integer
#  created_at  :datetime
#  updated_at  :datetime
#  published   :boolean
#  phase_id    :integer
#  modifiable  :boolean
#

FactoryBot.define do
  factory :section do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    sequence(:number)
    published false
    phase
    modifiable false
  end
end
