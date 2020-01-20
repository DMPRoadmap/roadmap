# == Schema Information
#
# Table name: sections
#
#  id             :integer          not null, primary key
#  title          :string
#  description    :text
#  number         :integer
#  created_at     :datetime
#  updated_at     :datetime
#  phase_id       :integer
#  modifiable     :boolean
#  versionable_id :string(36)
#
# Indexes
#
#  index_sections_on_versionable_id  (versionable_id)
#  sections_phase_id_idx             (phase_id)
#

FactoryBot.define do
  factory :section do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    sequence(:number)
    phase
    modifiable { false }

    transient do
      questions { 0 }
    end

    after(:create) do |section, evaluator|
      create_list(:question, evaluator.questions, section: section)
    end
  end
end
