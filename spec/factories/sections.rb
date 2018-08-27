# == Schema Information
#
# Table name: sections
#
#  id          :integer          not null, primary key
#  description :text(65535)
#  modifiable  :boolean
#  number      :integer
#  title       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  phase_id    :integer
#
# Indexes
#
#  index_sections_on_phase_id  (phase_id)
#
# Foreign Keys
#
#  fk_rails_...  (phase_id => phases.id)
#

FactoryBot.define do
  factory :section do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    sequence(:number)
    phase
    modifiable false
  end
end
