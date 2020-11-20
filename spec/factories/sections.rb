# frozen_string_literal: true

# == Schema Information
#
# Table name: sections
#
#  id             :integer          not null, primary key
#  description    :text
#  modifiable     :boolean
#  number         :integer
#  title          :string
#  created_at     :datetime
#  updated_at     :datetime
#  phase_id       :integer
#  versionable_id :string(36)
#
# Indexes
#
#  index_sections_on_phase_id        (phase_id)
#  index_sections_on_versionable_id  (versionable_id)
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
    modifiable { false }

    transient do
      questions { 0 }
    end

    after(:create) do |section, evaluator|
      create_list(:question, evaluator.questions, section: section)
    end
  end
end
