# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id                     :integer          not null, primary key
#  default_value          :text
#  modifiable             :boolean
#  number                 :integer
#  option_comment_display :boolean          default(TRUE)
#  text                   :text
#  created_at             :datetime
#  updated_at             :datetime
#  madmp_schema_id        :integer
#  question_format_id     :integer
#  section_id             :integer
#  versionable_id         :string(36)
#
# Indexes
#
#  index_questions_on_madmp_schema_id  (madmp_schema_id)
#  index_questions_on_versionable_id   (versionable_id)
#  questions_question_format_id_idx    (question_format_id)
#  questions_section_id_idx            (section_id)
#
# Foreign Keys
#
#  fk_rails_...  (madmp_schema_id => madmp_schemas.id)
#  fk_rails_...  (question_format_id => question_formats.id)
#  fk_rails_...  (section_id => sections.id)
#

FactoryBot.define do
  factory :question do
    section
    question_format
    text { Faker::Lorem.paragraph }
    sequence(:number)
    modifiable { false }

    transient do
      options { 0 }
    end

    before(:create) do |question, evaluator|
      question.question_options = create_list(:question_option, evaluator.options)
    end

    trait :textarea do
      question_format { create(:question_format, :textarea) }
    end

    trait :textfield do
      question_format { create(:question_format, :textfield) }
    end

    trait :radiobuttons do
      question_format { create(:question_format, :radiobuttons) }
    end

    trait :checkbox do
      question_format { create(:question_format, :checkbox) }
    end

    trait :dropdown do
      question_format { create(:question_format, :dropdown) }
    end

    trait :multiselectbox do
      question_format { create(:question_format, :multiselectbox) }
    end

    trait :date do
      question_format { create(:question_format, :date) }
    end

    trait :rda_metadata do
      question_format { create(:question_format, :rda_metadata) }
    end
  end
end
