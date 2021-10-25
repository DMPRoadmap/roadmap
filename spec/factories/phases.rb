# frozen_string_literal: true

# == Schema Information
#
# Table name: phases
#
#  id             :integer          not null, primary key
#  description    :text
#  modifiable     :boolean
#  number         :integer
#  title          :string
#  created_at     :datetime
#  updated_at     :datetime
#  template_id    :integer
#  versionable_id :string(36)
#
# Indexes
#
#  index_phases_on_template_id     (template_id)
#  index_phases_on_versionable_id  (versionable_id)
#
# Foreign Keys
#
#  fk_rails_...  (template_id => templates.id)
#

FactoryBot.define do
  factory :phase do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    sequence(:number)
    template
    modifiable { false }

    transient do
      sections { 0 }
      questions { 0 }
    end

    after(:create) do |phase, evaluator|
      create_list(:section, evaluator.sections, phase: phase, questions: evaluator.questions)
    end
  end
end
