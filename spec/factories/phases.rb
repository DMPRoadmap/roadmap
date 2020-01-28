# == Schema Information
#
# Table name: phases
#
#  id             :integer          not null, primary key
#  title          :string
#  description    :text
#  number         :integer
#  template_id    :integer
#  created_at     :datetime
#  updated_at     :datetime
#  modifiable     :boolean
#  versionable_id :string(36)
#
# Indexes
#
#  index_phases_on_versionable_id  (versionable_id)
#  phases_template_id_idx          (template_id)
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
