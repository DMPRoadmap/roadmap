# == Schema Information
#
# Table name: questions
#
#  id                     :integer          not null, primary key
#  text                   :text
#  default_value          :text
#  number                 :integer
#  section_id             :integer
#  created_at             :datetime
#  updated_at             :datetime
#  question_format_id     :integer
#  option_comment_display :boolean          default(TRUE)
#  modifiable             :boolean
#

FactoryBot.define do
  factory :question do
    section
    question_format
    text { Faker::Lorem.paragraph }
    sequence(:number)
    modifiable false

    transient do
      options 0
    end

    after(:create) do |question, evaluator|
      create_list(:question_option, evaluator.options, question: question)
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
